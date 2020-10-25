import $ from 'jquery'
import { Radio } from 'backbone'

import scroll_top_fast from 'tbirds/util/scroll-top-fast'
import { MainController } from 'tbirds/controllers'

import './dbchannel'

MiscViews = require './views/misc'

AppChannel = Radio.channel 'bumblr'


class Controller extends MainController
  set_header: (title) ->
    header = $ '#header'
    header.text title
    
  start: ->
    #console.log 'bumblr start called'
    @setupLayoutIfNeeded()
    @set_header 'Bumblr'
    @listBlogs()

  default_view: ->
    @start()
    
  show_mainview: () ->
    view = new MiscViews.MainBumblrView
    @layout.showChildView 'content', view
    scroll_top_fast()
    
  showDashboard: () ->
    view = new MiscViews.BumblrDashboardView
    @layout.showChildView 'content', view
    scroll_top_fast()
      
  listBlogs: () ->
    @setupLayoutIfNeeded()
    require.ensure [], () =>
      blogs = AppChannel.request 'get-local-blogs'
      SimpleBlogListView = require('./views/bloglist').default
      view = new SimpleBlogListView
        collection: blogs
      @layout.showChildView 'content', view
    # name the chunk
    , 'bumblr-view-list-blogs'
    
  viewBlog: (blog_id) ->
    #console.log 'view blog called for ' + blog_id
    @setupLayoutIfNeeded()
    require.ensure [], () =>
      host = "#{blog_id}.tumblr.com"
      collection = AppChannel.request 'make-blog-post-collection', host
      BlogPostListView = require('./views/postlist').default
      response = collection.fetch()
      response.done =>
        view = new BlogPostListView
          collection: collection
        @layout.showChildView 'content', view
        scroll_top_fast()
    # name the chunk
    , 'bumblr-view-blog-view'
    
  viewBlogPix: (blog_id) ->
    #console.log 'view blog called for ' + blog_id
    @setupLayoutIfNeeded()
    require.ensure [], () =>
      host = "#{blog_id}.tumblr.com"
      collection = AppChannel.request 'make-pix-collection', host
      window.pix = collection
      View = require('./views/picview').default
      response = collection.getFirstPage()
      response.done =>
        view = new View
          collection: collection
        @layout.showChildView 'content', view
        scroll_top_fast()
    # name the chunk
    , 'bumblr-view-blog-view'
    
  addNewBlog: () ->
    @setupLayoutIfNeeded()
    require.ensure [], () =>
      NewBlogFormView = require('./views/newblog').default
      view = new NewBlogFormView
      @layout.showChildView 'content', view
      scroll_top_fast()
    # name the chunk
    , 'bumblr-view-add-blog'
    
          
  settingsPage: () ->
    @setupLayoutIfNeeded()
    require.ensure [], () =>
      ConsumerKeyFormView = require('./views/settingsform').default
      settings = AppChannel.request 'get_app_settings'
      view = new ConsumerKeyFormView model:settings
      @layout.showChildView 'content', view
      scroll_top_fast()
    # name the chunk
    , 'bumblr-view-settings'
    
export default Controller

