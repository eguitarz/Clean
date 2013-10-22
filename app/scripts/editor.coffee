@Editor = class Editor
	titlePromptMessage: 'New title'
	promptMessage: 'Type your article here'
	status:
		cmd: false
		ctrl: false
		alt: false
		shift: false
		empty: false
		titleEmpty: false
		new: true
		connecting: false
	displayPrompt: ->
		$('#editor').children().first().html '<span class="prompt">'+@promptMessage+'</span>'
	displayTitlePrompt: ->
		$('#editor-title').html '<span class="prompt">'+@titlePromptMessage+'</span>'
	clear: ->
		$('#editor').children().first().html('<br>')
	clearTitle: ->
		$('#editor-title').html ''
	selection: ->
		window.getSelection() if window.getSelection
	saveSelection: ->
		sel = @selection()
		if sel.getRangeAt && sel.rangeCount
			range = sel.getRangeAt 0
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
		@status.cmd = @status.ctrl = @status.alt = @status.shift = false
	rand: (len=4)->
		result = ''
		result += Math.random().toString(36).substr(2,1) for i in new Array(len)
		result.toUpperCase()
	divsToPs: ->
		#transform divs to ps
		@saveSelection()
		$('#editor div').not('[name]').each ->
			el = $('<p>')
			el.html $(@).html()
			$(@).after(el)
			$(@).remove()
		@restoreSelection()
	assignNameAttribute: (jqel)->
		jqel.attr 'name', @rand()
	showInsertion: ->
		$('#insertion').removeClass 'hidden'
	hideInsertion: ->
		$('#insertion').addClass 'hidden'
		$('#insertion .expand-area').removeClass 'expand'
	setInsertionTop: (top)->
		$('#insertion').css 'top', top
	delegateEvents: ()->
		self = @
		$('#editor').delegate 'h1,h2,p,pre,code', 'mousemove', (e)->
			$(@).addClass('hovered').siblings().removeClass('hovered')
			parentOffset = $(@).parent().offset()
			thisOffset = $(@).offset()
			height = $(@).outerHeight()
			return if self.status.empty || self.status.new
			if height >= 30
				if thisOffset.top + height - e.pageY < 30 && thisOffset.top + height - e.pageY > 0
					self.showInsertion()
					self.setInsertionTop thisOffset.top - parentOffset.top + height - 15
				else
					self.hideInsertion()
			else
				self.showInsertion()
				self.setInsertionTop thisOffset.top - parentOffset.top + height

		# insertion add btn event
		$('#insertion').delegate '.btn-add', 'click', (e)->
			$('#insertion .expand-area').toggleClass 'expand'

	update: ->
		self = @
		# giving names
		$('#editor p,h1,h2,pre').not('[name]').each ->
			$(@).attr 'name', self.rand()
		# remove undeletable empty elements
		$('#editor').children().each ->
			$(@).remove() if $(@).html() == ''
		# debug
		$('#debug').text $('#editor').html()
	updateTitlePrompt: (clear)->
		throw new Exception 'undefined args' if typeof clear == 'undefined'
		@checkTitleEmpty()
		if @status.titleEmpty
			if clear then @clearTitle() else @displayTitlePrompt()
	updatePrompt: (clear)->
		throw new Exception 'undefined args' if typeof clear == 'undefined'
		@checkEmpty()
		if @status.empty
			if clear then @clear() else @displayPrompt()
	checkNew: ->
		if $('#editor').text().length > 5
			@status.new = false
			$('#editor').trigger 'askid'
	checkTitleEmpty: ->
		@status.titleEmpty = $('#editor-title').text() == '' || $('#editor-title').text() == @titlePromptMessage
	checkEmpty: ->
		@status.empty = $('#editor').text() == '' || $('#editor').text() == @promptMessage
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
	handleTitleKeyDown: (e)->
		switch e.keyCode
			when 13
				e.preventDefault()
				e.stopPropagation()
	handleTitleKeyUp: (e)->
		console.log 'title keyup'
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
					@toggleFormatBlock 'h2'
					e.preventDefault()
					e.stopPropagation()
			when 51
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
			when 8
				if $('#editor').html().match /^<(h1|h2|p|pre|code) name=".{4}"><br><\/(h1|h2|p|pre|code)>$/
					e.preventDefault()
					e.stopPropagation()

	handleKeyUp: (e)->
		# debug
		$('#debug-keyup').text e.keyCode

		switch e.keyCode
			when 13
				@divsToPs()
				@assignNameAttribute @getSelectedElement()
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
	constructor: (options={})->
		@id = options.id
		@status.new = !@id
		@askid = options.askid
		@articleCreateURL = options.articleCreateURL
		@articleSaveURL = options.articleSaveURL
		@articleDeleteURL = options.articleDeleteURL

	init: ()->
		self = @
		$('#editor').html '<p><br></p>' if @status.new
		@update()
		@checkTitleEmpty()
		@checkEmpty()
		@displayTitlePrompt() if @status.titleEmpty
		@displayPrompt() if @status.empty
		@bindEditorTitleEvents()
		@bindEditorEvents()

	bindEditorTitleEvents:->
		$('#editor-title').on 'keydown', (e)=>
			@handleTitleKeyDown(e)
		.on 'keyup', (e)=>
			@handleTitleKeyUp(e)
		.on 'paste', (e)=>
			e.preventDefault()
			raw = e.clipboardData.getData('text/html') || e.clipboardData.getData('text')
			pasteElement = document.createElement 'p'
			pasteElement.innerHTML = raw
			$(pasteElement).find('*').each ->
				attributes = $.map @attributes, (item)->
					item.name
				$.each attributes, (i, key)=>
					$(@).removeAttr(key)
			self = @
			document.execCommand 'insertHtml', false, $(pasteElement).text()
		.blur =>
			@updateTitlePrompt(false)
		.focus =>
			@updateTitlePrompt(true)

	bindEditorEvents: ->
		$('#editor').on 'keydown', (e)=>
			@hideInsertion()
			@checkNew() if @status.new
			@handleKeyDown(e)
			@update()
		.on 'keyup', (e)=>
			@handleKeyUp(e)
			@update()
			@checkEmpty()
		.on 'click', (e)->
			$(@).focus()
		.on 'paste', (e)=>
			e.preventDefault()
			raw = e.clipboardData.getData('text/html') || e.clipboardData.getData('text')
			pasteElement = document.createElement 'p'
			pasteElement.innerHTML = raw
			$(pasteElement).find('*').each ->
				attributes = $.map @attributes, (item)->
					item.name
				$.each attributes, (i, key)=>
					$(@).removeAttr(key)
			result = $(pasteElement).html()
				.replace( new RegExp('h[3-9]', 'ig'), 'h2' )
				.removeTagsExcept(['p', 'h1', 'h2', 'a', 'br', 'pre', 'code'])
			document.execCommand 'insertHtml', false, result
		.on 'askid', =>
			if @askid
				@askid( @ ) unless @status.connecting
			else
				@id = 'A00000'
		.blur =>
			@updatePrompt(false)
			@clearStatus()
			# @hideInsertion()
		.focus =>
			@updatePrompt(true)
			@update()
			@clearStatus()

		# dynamic events
		@delegateEvents()