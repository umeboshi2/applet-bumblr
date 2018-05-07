import $ from 'jquery'
import Backbone from 'backbone'
import PageableCollection from 'backbone.paginator'

import { LoveStore } from 'backbone.lovefield'
import { BaseLocalStorageCollection } from 'tbirds/lscollection'
import BaseLocalStorageModel from 'tbirds/base-localstorage-model'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'bumblr'

dbConn = MainChannel.request 'main:app:dbConn', 'bumblr'
baseURL = '//api.tumblr.com/v2'

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
    #offset = currentPage * @state.pageSize
    #options.offset = offset
    options.dataType = 'jsonp'
    super options
    
  parse: (response) ->
    console.log "PARSE", response
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
    
class BaseTumblrModel extends Backbone.Model
  baseURL: baseURL
  
class BlogInfo extends BaseTumblrModel
  url: () ->
    "#{@baseURL}/blog/#{@id}/info?api_key=#{@apiKey}&callback=?"

class PhotoPostCollection extends Backbone.Collection
  url: () ->
    "#{baseURL}/#{@id}/posts/photo?callback=?"
    




class BumblrSettings extends BaseLocalStorageModel
  id: 'bumblr_settings'
  
settings = new BumblrSettings()
AppChannel.reply 'get_app_settings', ->
  return settings

consumer_key = '4mhV8B1YQK6PUA2NW8eZZXVHjU55TPJ3UZnZGrbSoCnqJaxDyH'
skey = settings.get 'consumer_key'
if not skey
  console.log "saving initial app settings"
  settings.set 'consumer_key', consumer_key
  settings.save()


BlogStore = new LoveStore dbConn, 'Blog'


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
  
