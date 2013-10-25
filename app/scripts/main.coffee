'use strict'
@Clean = @Clean || {}

@Clean = Ember.Application.create
  LOG_TRANSITIONS: true
  rootElement: '#application'

@Clean.editor = new Editor 
  askid: (editor)->
    # status.connecting = true
    editor.setConnecting true
    $.ajax
    url: 'http://localhost:3000'
    success: (data)->
      console.log 'ask id success'
      editor.id = 'MOCKID123'
      # editor.status.connecting = false
      editor.setConnecting false
    error: ->
      console.log 'unable to ask id'
      # editor.status.connecting = false
      editor.setConnecting false