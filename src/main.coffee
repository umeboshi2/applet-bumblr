import Marionette from 'backbone.marionette'

import TkApplet from 'tbirds/tkapplet'

import Controller from './controller'

MainChannel = Backbone.Radio.channel 'global'
BumblrChannel = Backbone.Radio.channel 'bumblr'



class Router extends Marionette.AppRouter
  appRoutes:
    'bumblr': 'start'
    'bumblr/settings': 'settings_page'
    'bumblr/dashboard': 'show_dashboard'
    'bumblr/listblogs': 'list_blogs'
    'bumblr/viewblog/:id': 'view_blog'
    'bumblr/addblog' : 'add_new_blog'


class Applet extends TkApplet
  Controller: Controller
  Router: Router

  onBeforeStart: ->
    blog_collection = BumblrChannel.request 'get_local_blogs'
    # FIXME use better lscollection
    blog_collection.fetch()
    super arguments
  

export default Applet
