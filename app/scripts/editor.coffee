class Editor
	status:
		cmd: false
		ctrl: false
		alt: false
		shift: false
		empty: false
	update: ->
		$('#debug').text $('#editor').html()
	handleKeyDown: (e)->
		$('#debug-keydown').text e.keyCode
		console.log $('#debug-keydown').text()
	handleKeyUp: (e)->
		$('#debug-keyup').text e.keyCode
		console.log e.keyCode
	init: ->
		@update()

		# binding
		$('#editor').on 'keyup', (e)=>
			@update()
			@handleKeyUp(e)
		.on 'keydown', (e)=>
			console.log e
			@handleKeyDown(e)

$(document).ready ->
	editor = new Editor
	editor.init()