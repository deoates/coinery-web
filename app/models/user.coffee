module.exports = class User extends Backbone.Model

  url: "#{window.api_root}/user"

  initialize: (options) ->

  getName: ->
    @get 'full_name'

  setValidSession: ->
    @set 'validated_session', true

  getValidSession: ->
    @get 'validated_session'

  getTwitterHandle: ->
    "@#{@get('username')}"

  getCoinbaseAuth: ->
    @get 'coinbase_auth'
