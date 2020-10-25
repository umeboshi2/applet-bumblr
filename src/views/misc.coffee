import { View as MnView } from 'backbone.marionette'
import tc from 'teacup'

export class MainBumblrView extends MnView
  template: tc.renderable ->
    tc.p 'main bumblr view'

export class BumblrDashboardView extends MnView
  template: tc.renderable ->
    tc.p 'bumblr_dashboard_view'
  
