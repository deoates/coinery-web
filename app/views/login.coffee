Template = require 'templates/login'

module.exports = class LoginView extends Backbone.View

  el: '.content'

  events: ->
    'click a[data-href="login"]': 'loginHandler'


  initialize: ->
    @user = @model

  render: ->
    @$el.html Template {}

  loginHandler: (e) ->
    root = window.api_root.replace '/api',''
    window.location.href = root+"/auth/twitter"

