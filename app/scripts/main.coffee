$(document).ready ->
  window.e = editor = new Editor 
  	askid: (status)->
  		status.connecting = true
  		$.ajax
  		 url: 'http://localhost:3000'
  		 success: (data)->
  		 	console.log 'ask id success'
  		 	status.connecting = false
  		 error: ->
  		 	console.log 'unable to ask id'
  		 	status.connecting = false
  editor.init()