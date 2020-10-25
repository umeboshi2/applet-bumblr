import { Radio } from 'backbone'
import AppRouter from 'tbirds/routers/approuter'
import TkApplet from 'tbirds/tkapplet'

import Controller from './controller'

AppChannel = Radio.channel 'bumblr'

class Router extends AppRouter
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
    blog_collection = AppChannel.request 'get-local-blogs'
    # FIXME use better lscollection
    blog_collection.fetch()
    if blog_collection.isEmpty()
      ['dutch-and-flemish-painters', 'gkar56', 'japanesesuburbia',
      '8bitfuture', 'elfwud', 'hexeosis', 'pixel8or',
      'necessary-disorder'].forEach (blog) ->
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
