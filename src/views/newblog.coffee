import { Radio, Model } from 'backbone'
import tc from 'teacup'

import BootstrapFormView  from 'tbirds/views/bsformview'
import { form_group_input_div } from 'tbirds/templates/forms'
import navigate_to_url from 'tbirds/util/navigate-to-url'

AppChannel = Radio.channel 'bumblr'

########################################
new_blog_form_view = tc.renderable ->
  form_group_input_div
    input_id: 'input_blogname'
    label: 'Blog Name'
    input_attributes:
      name: 'blog_name'
      placeholder: ''
      value: 'dutch-and-flemish-painters'
  tc.input '.btn.btn-default.btn-xs', type:'submit', value:'Add Blog'

########################################

class NewBlogFormView extends BootstrapFormView
  template: new_blog_form_view
  ui:
    blog_name: '[name="blog_name"]'

  updateModel: ->
    #console.log 'updateModel'
    @collection = AppChannel.request 'get-local-blogs'
    @model = @collection.addBlog @ui.blog_name.val()

  onSuccess: ->
    #console.log 'onSuccess called'
    navigate_to_url '#bumblr/listblogs'

  createModel: ->
    return new Model url:'/'

export default NewBlogFormView


