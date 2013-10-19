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
		# debug
		$('#debug-keydown').text e.keyCode

		switch e.keyCode
			when 16 then @status.shift = true
			when 17 then @status.ctrl = true
			when 18 then @status.alt = true
			when 91 then @status.cmd = true

	handleKeyUp: (e)->
		# debug
		$('#debug-keyup').text e.keyCode

		switch e.keyCode
			when 16 then @status.shift = false
			when 17 then @status.ctrl = false
			when 18 then @status.alt = false
			when 91 then @status.cmd = false

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