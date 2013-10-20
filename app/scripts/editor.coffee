@Editor = class Editor
	promptMessage: 'Type your article here'
	status:
		cmd: false
		ctrl: false
		alt: false
		shift: false
		empty: false
	displayPrompt: ->
		$('#editor').html "<span class=\"prompt\">#{@promptMessage}</p>"
	hidePrompt: ->
		$('#editor').html '<p><br></p><p></p>'
	selection: ->
		window.getSelection() if window.getSelection
	saveSelection: ->
		sel = @selection()
		if sel.getRangeAt && sel.rangeCount
			range = sel.getRangeAt 0
			$('.selection').text range.toString()

			cursorStart = document.createElement 'span'
			cursorStart.id = 'cursorStart'
			range.insertNode cursorStart
			if !range.collapsed
				cursorEnd = document.createElement 'span'
				cursorEnd.id = 'cursorEnd'
				range.collapse()
				range.insertNode cursorEnd
	restoreSelection: ->
		cursorStart = document.getElementById 'cursorStart'
		cursorEnd = document.getElementById 'cursorEnd'
		range = document.createRange()
		if cursorStart
			sel = @selection()
			if cursorEnd
				range.setStartAfter cursorStart
				range.setEndBefore cursorEnd
				cursorStart.parentNode.removeChild cursorStart
				cursorEnd.parentNode.removeChild cursorEnd
			else
				range.selectNode cursorStart
			# select range
			sel.removeAllRanges()
			sel.addRange range
	getSelectedElement: ->
		el = $(@selection().getRangeAt(0).commonAncestorContainer)
		return if el[0].nodeType == 3 then el.parent() else el
	clearStatus: ->
		$('.debug-status').addClass 'hidden'
		@status.cmd = @status.ctrl = @status.alt = @status.shift = @status.empty = false
	rand: (len=4)->
		result = ''
		result += Math.random().toString(36).substr(2,1) for i in new Array(len)
		result.toUpperCase()
	update: ->
		self = @
		$('p,h1,h2,pre').not('[name]').each ->
			$(@).attr 'name', self.rand()
		$('#debug').text $('#editor').html()
	toggleFormatBlock: (tag)->
		el = @getSelectedElement()
		if el.attr 'name'
			@saveSelection()
			if el.is tag
				newEl = $('<p>').html el.html()
				newEl.attr 'name', el.attr 'name'
				el.after(newEl)
				el.remove()
				@restoreSelection()
			else
				newEl = $("<#{tag}>").html el.html()
				newEl.attr 'name', el.attr 'name'
				el.after(newEl)
				el.remove()
				@restoreSelection()
		else
			document.execCommand('formatBlock', false, tag)
	handleKeyDown: (e)->
		# debug
		$('#debug-keydown').text e.keyCode

		switch e.keyCode
			when 49
				if @status.cmd or @status.ctrl
					@toggleFormatBlock 'h1'
					e.preventDefault()
					e.stopPropagation()
			when 50
				if @status.cmd or @status.ctrl
					@toggleFormatBlock 'pre'
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
		@displayPrompt()

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
			@displayPrompt()
			@clearStatus()
		.focus =>
			@hidePrompt()
			@update()
			@clearStatus()