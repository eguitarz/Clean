class Editor
	update: ->
		$('#debug').text $('#editor').html()
	handleKeyUp: (e)->
		console.log e.keyCode
	init: ->
		@update()

		# binding
		$('#editor').on 'keyup', (e)=>
			@update()
			@handleKeyUp(e)

$(document).ready ->
	editor = new Editor
	editor.init()