'use strict'
@Clean = @Clean || {}

@Clean = Ember.Application.create
  LOG_TRANSITIONS: true
  rootElement: '#application'
console.log @Clean

@Clean.editor = new Editor 
	askid: (editor)->
		status.connecting = true
		$.ajax
		 url: 'http://localhost:3000'
		 success: (data)->
		 	console.log 'ask id success'
		 	editor.id = 'MOCKID123'
		 	editor.status.connecting = false
		 error: ->
		 	console.log 'unable to ask id'
		 	editor.status.connecting = false