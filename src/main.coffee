import Marionette from 'backbone.marionette'

import TkApplet from 'tbirds/tkapplet'

import Controller from './controller'

MainChannel = Backbone.Radio.channel 'global'
BumblrChannel = Backbone.Radio.channel 'bumblr'



class Router extends Marionette.AppRouter
  appRoutes:
    'bumblr': 'start'
    'bumblr/settings': 'settingsPage'
    'bumblr/dashboard': 'showDashboard'
    'bumblr/listblogs': 'listBlogs'
    'bumblr/viewblog/:id': 'viewBlog'
    'bumblr/addblog' : 'addNewBlog'
    'bumblr/viewpix/:id': 'viewBlogPix'
    


class Applet extends TkApplet
  Controller: Controller
  Router: Router

  onBeforeStart: ->
    blog_collection = BumblrChannel.request 'get-local-blogs'
    # FIXME use better lscollection
    blog_collection.fetch()
    if blog_collection.isEmpty()
      ['dutch-and-flemish-painters', 'gkar56', 'flowerfood',
      '8bitfuture', 'dendroica'].forEach (blog) ->
        blog_collection.addBlog blog
    super arguments
  
  appletEntries: [
    {
      label: "Bumblr Menu"
      menu: [
        {
          label: 'List Blogs'
          url: '#bumblr/listblogs'
          icon: '.fa.fa-list'
        }
        {
          label: 'Add Blog'
          url: '#bumblr/addblog'
          icon: '.fa.fa-plus'
        }
        {
          label: 'Settings'
          url: '#bumblr/settings'
          icon: '.fa.fa-gear'
        }
      ]
    }
  ]


export default Applet
