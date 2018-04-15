import $ from 'jquery'
import Backbone from 'backbone'
import PageableCollection from 'backbone.paginator'

import { BaseLocalStorageCollection } from 'tbirds/lscollection'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'bumblr'

baseURL = '//api.tumblr.com/v2'

class BaseLocalStorageModel extends Backbone.Model
  initialize: ->
    @fetch()
    @on 'change', @save, @
  fetch: () ->
    @set JSON.parse localStorage.getItem @id
  save: (attributes, options) ->
    localStorage.setItem(@id, JSON.stringify(@toJSON()))
    return $.ajax
      success: options.success
      error: options.error
  destroy: (options) ->
    return localStorage.removeItem @id
  isEmpty: () ->
    return _.size @attributes <= 1

    
class BlogPosts extends PageableCollection
  mode: 'server'
  full: true
  baseURL: baseURL
  url: ->
    return "#{@baseURL}/blog/#{@blogName}/posts/photo?api_key=#{@apiKey}"

  fetch: (options) ->
    options || options = {}
    data = (options.data || {})
    currentPage = @state.currentPage
    offset = currentPage * @state.pageSize
    options.offset = offset
    options.dataType = 'jsonp'
    super options
    
  parse: (response) ->
    total_posts = response.response.total_posts
    @state.totalRecords = total_posts
    super response.response.posts
  state:
    firstPage: 0
    pageSize: 15
    
  queryParams:
    pageSize: 'limit'
    offset: () ->
      @state.currentPage * @state.pageSize
    
class BumblrSettings extends BaseLocalStorageModel
  id: 'bumblr_settings'
  
class BaseTumblrModel extends Backbone.Model
  baseURL: baseURL
  
class BlogInfo extends BaseTumblrModel
  url: () ->
    "#{@baseURL}/blog/#{@id}/info?api_key=#{@apiKey}&callback=?"

class PhotoPostCollection extends Backbone.Collection
  url: () ->
    "#{baseURL}/#{@id}/posts/photo?callback=?"
    




consumer_key = '4mhV8B1YQK6PUA2NW8eZZXVHjU55TPJ3UZnZGrbSoCnqJaxDyH'
settings = new BumblrSettings()
skey = settings.get 'consumer_key'
if not skey
  console.log "saving initial app settings"
  settings.set 'consumer_key', consumer_key
  settings.save()

AppChannel.reply 'get_app_settings', ->
  return settings



class LocalBlogCollection extends BaseLocalStorageCollection
  model: BlogInfo
  addBlog: (name) ->
    siteName = "#{name}.tumblr.com"
    atts =
    model = new @model
      id: siteName
      name: name
    model.apiKey = settings.get 'consumer_key'
    @add model
    r = model.fetch()
    r.done =>
      @save()
    return model
    

AppChannel.reply 'make-blog-post-collection', (blogName) ->
  apiKey = settings.get 'consumer_key'
  posts = new BlogPosts
  posts.apiKey = apiKey
  posts.blogName = blogName
  return posts

AppChannel.reply 'make-pix-collection', (blogName) ->
  apiKey = settings.get 'consumer_key'
  posts = new BlogPosts
  posts.state =
    firstPage: 0
    pageSize: 1
  posts.apiKey = apiKey
  posts.blogName = blogName
  return posts
  
localBlogs = new LocalBlogCollection
  apiKey: settings.get 'consumer_key'
AppChannel.reply 'get-local-blogs', ->
  return localBlogs
  
