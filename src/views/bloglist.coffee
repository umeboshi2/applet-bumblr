$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
tc = require 'teacup'

navigate_to_url = require('tbirds/util/navigate-to-url').default

BumblrChannel = Backbone.Radio.channel 'bumblr'

########################################
blog_dialog_view = tc.renderable (blog) ->
  tc.div '.modal-header', ->
    tc.h2 'This is a modal!'
  tc.div '.modal-body', ->
    tc.p 'here is some content'
  tc.div '.modal-footer', ->
    tc.button '#modal-cancel-button.btn', 'cancel'
    tc.button '#modal-ok-button.btn.btn-default', 'Ok'

simple_blog_info = tc.renderable (blog) ->
  tc.div '.blog.listview-list-entry', ->
    tc.i '.show-pix.fa.fa-eye.btn-default'
    tc.a href:'#bumblr/viewblog/' + blog.name, blog.name
    tc.i ".delete-blog-button.fa.fa-close.btn-default",
    blog:blog.name

simple_blog_list = tc.renderable () ->
  tc.div ->
    tc.a '.btn.btn-default', href:'#bumblr/addblog', "Add blog"
    tc.div '#bloglist-container.listview-list'

########################################
class BlogModal extends Marionette.View
  template: blog_dialog_view

class SimpleBlogInfoView extends Marionette.View
  template: simple_blog_info
  ui:
    deleteButton: '.delete-blog-button'
    showPixButton: '.show-pix'
  events:
    'click @ui.showPixButton': 'showPix'
    'click @ui.deleteButton': 'deleteBlog'
  onDomRefresh: ->
    handlerIn = (event) =>
      @ui.deleteButton.show()
    handlerOut = (event) =>
      #setTimeout () =>
      #  @ui.deleteButton.hide()
      #, 200
      @ui.deleteButton.hide()
    @$el.hover handlerIn, handlerOut
    @ui.deleteButton.hide()
    
  showPix: ->
    name = @model.get 'name'
    #console.log "name is ", name
    navigate_to_url "#bumblr/viewpix/#{name}"

  deleteBlog: ->
    console.log "deleteBlog", @model
    collection = @model.collection
    @model.destroy()
    collection.save()
    # fixme do this in parent view
    #@masonry.reloadItems()
    #@masonry.layout()
    
class SimpleBlogListView extends Marionette.CollectionView
  childView: SimpleBlogInfoView
  template: simple_blog_list
  childViewContainer: '#bloglist-container'
  ui:
    blogs: '#bloglist-container'
    
  onBeforeDestroy: ->
    @masonry.destroy()
    
  onDomRefresh: () ->
    console.log 'onDomRefresh called on SimpleBlogListView'
    @masonry = new Masonry "#bloglist-container",
      gutter: 2
      isInitLayout: false
      itemSelector: '.blog'
      columnWidth: 100
    @set_layout()

  set_layout: ->
    @masonry.reloadItems()
    @masonry.layout()

module.exports = SimpleBlogListView
