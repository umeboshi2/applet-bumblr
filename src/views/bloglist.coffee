import $ from 'jquery'
import { View as MnView, CollectionView } from 'backbone.marionette'
import Masonry from 'masonry-layout'
import tc from 'teacup'
import navigate_to_url from 'tbirds/util/navigate-to-url'


########################################
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
class SimpleBlogInfoView extends MnView
  template: simple_blog_info
  ui:
    deleteButton: '.delete-blog-button'
    showPixButton: '.show-pix'
  events:
    'click @ui.showPixButton': 'showPix'
    'click @ui.deleteButton': 'deleteBlog'
  onDomRefresh: ->
    handlerIn = () =>
      @ui.deleteButton.show()
    handlerOut = () =>
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
    #console.log "deleteBlog", @model
    collection = @model.collection
    @model.destroy()
    collection.save()
    # fixme do this in parent view
    #@masonry.reloadItems()
    #@masonry.layout()
    
class SimpleBlogListView extends CollectionView
  childView: SimpleBlogInfoView
  template: simple_blog_list
  childViewContainer: '#bloglist-container'
  ui:
    blogs: '#bloglist-container'
    
  onBeforeDestroy: ->
    @masonry.destroy()
    
  onDomRefresh: ->
    #console.log 'onDomRefresh called on SimpleBlogListView'
    @masonry = new Masonry "#bloglist-container",
      gutter: 2
      isInitLayout: false
      itemSelector: '.blog'
      columnWidth: 100
    @set_layout()

  set_layout: ->
    @masonry.reloadItems()
    @masonry.layout()

export default  SimpleBlogListView
