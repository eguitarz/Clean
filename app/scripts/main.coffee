'use strict'
@Clean = @Clean || {}

@Clean = Ember.Application.create
  LOG_TRANSITIONS: true
  rootElement: '#application'

@Clean.editor = new Editor 
  askid: (editor)->
    editor.setConnecting true
    $.ajax
    url: 'http://localhost:3000'
    success: (data)->
      console.log 'ask id success'
      editor.id = 'MOCKID123'
      editor.setConnecting false
    error: ->
      console.log 'unable to ask id'
      editor.setConnecting false
  autosaveCallback: ->
    editor.setConnecting true
    $.ajax
    url: 'http://localhost:3000'
    success: (data)->
      console.log 'autosave success'
      editor.setConnecting false
    error: ->
      console.log 'unable to autosave'
      editor.setConnecting false