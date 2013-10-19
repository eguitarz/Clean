@Editor = class Editor
	status:
		cmd: false
		ctrl: false
		alt: false
		shift: false
		empty: false
	selection: ->
		sel = window.getSelection()
		$('.selection').text sel.getRangeAt(0).toString()
		sel
	getSelectedElement: ->
		el = $(@selection().getRangeAt(0).commonAncestorContainer)
		return if el[0].nodeType == 3 then el.parent() else el
	clearStatus: ->
		$('.debug-status').addClass 'hidden'
		status.cmd = status.ctrl = status.alt = status.shift = status.empty = false
	update: ->
		$('#debug').text $('#editor').html()
	handleKeyDown: (e)->
		# debug
		$('#debug-keydown').text e.keyCode

		switch e.keyCode
			when 49
				if @status.cmd || @status.ctrl
					# document.execCommand('formatBlock', false, 'h1')
					el = @getSelectedElement()
					console.log 'selected el'
					console.log el
					if el.is 'h1'
						(new Command('formatBlock', 'p') ).run()
					else
						(new Command('formatBlock', 'h1') ).run()
					e.preventDefault()
					e.stopPropagation()
			when 16
				@status.shift = true
				$('.shift').removeClass('hidden')
			when 17
				@status.ctrl = true
				$('.ctrl').removeClass('hidden')
			when 18
				@status.alt = true
				$('.alt').removeClass('hidden')
			when 91
				@status.cmd = true
				$('.cmd').removeClass('hidden')

	handleKeyUp: (e)->
		# debug
		$('#debug-keyup').text e.keyCode

		switch e.keyCode
			when 16
				@status.shift = false
				$('.shift').addClass('hidden')
			when 17
				@status.ctrl = false
				$('.ctrl').addClass('hidden')
			when 18
				@status.alt = false
				$('.alt').addClass('hidden')
			when 91
				@status.cmd = false
				$('.cmd').addClass('hidden')

	init: ->
		@update()

		# binding
		$('#editor').on 'keydown', (e)=>
			@handleKeyDown(e)
			@update()
		.on 'keyup', (e)=>
			@handleKeyUp(e)
			@update()
			@selection()
		.on 'mouseup', (e)=>
			@selection()
		.blur =>
			@clearStatus()
		.focus =>
			@clearStatus()