@Editor = class Editor

	## PROPERTIES ##
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
		changed: false
		showToolpad: false
		showTooltip: false

	## INITIALIZERS AND ACCESSORS ##
	constructor: (options={})->
		@id = options.id
		@status.new = !@id
		@defaultTitle = options.title
		@defaultContent = options.content
		@newPostCallback = options.newPostCallback
		@autosaveCallback = options.autosaveCallback
	init: ()->
		self = @
		$('#editor').html '<p><br></p>'
		$('#editor-title').text @defaultTitle if @defaultTitle
		$('#editor').html @defaultContent if @defaultContent
		@autosave 5000
		@update()
		@checkTitleEmpty()
		@checkEmpty()
		@displayTitlePrompt() if @status.titleEmpty
		@displayPrompt() if @status.empty
		@bindEditorTitleEvents()
		@bindAllEvents()
	setConnecting: (bool)->
		@status.connecting = bool
	setChanged: (bool)->
		@status.changed = bool
	setNew: (bool)->
		@status.new = bool

	## HELPERS ##
	assignNameAttribute: (jqel)->
		jqel.attr 'name', @rand()
	rand: (len=4)->
		result = ''
		result += Math.random().toString(36).substr(2,1) for i in new Array(len)
		result.toUpperCase()
	detectContentsChanged: ->
			title = $('#editor-title').html()
			content = $('#editor').html()
			if @lastTitle != title || @lastContent != content
				@setChanged true
				@lastTitle = title
				@lastContent = content
	autosave: (durationInMilliseconds=5000)->
		(update= =>
			setTimeout =>
				if @id && @status.changed && !@status.connecting
					@setChanged false
					@autosaveCallback(@) if @autosaveCallback
				update()
			, durationInMilliseconds)()
	applyOrCancelUrl: (range, url)->
		@selection().removeAllRanges()
		@selection().addRange range
		if url
			document.execCommand('createlink', false, url)
		else 
			document.execCommand('unlink', false)
	
	## RANGE OPERATIONS ##
	selection: ->
		window.getSelection() if window.getSelection
	saveSelection: (prefix='cursor')->
		sel = @selection()
		if sel.getRangeAt && sel.rangeCount
			$('#'+prefix+'Start').remove()
			$('#'+prefix+'End').remove()
			range = sel.getRangeAt 0
			cursorStart = document.createElement 'span'
			cursorStart.id = prefix+'Start'
			range.insertNode cursorStart
			if !range.collapsed
				cursorEnd = document.createElement 'span'
				cursorEnd.id = prefix+'End'
				range.collapse()
				range.insertNode cursorEnd
	restoreSelection: (prefix='cursor')->
		cursorStart = document.getElementById prefix+'Start'
		cursorEnd = document.getElementById prefix+'End'
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
	
	## UI RELATED OPERATIONS ##
	displayPrompt: ->
		$('#editor').children().first().html '<span class="prompt">'+@promptMessage+'</span>'
	displayTitlePrompt: ->
		$('#editor-title').html '<span class="prompt">'+@titlePromptMessage+'</span>'
	clear: ->
		$('#editor').children().first().html('<br>')
	clearTitle: ->
		$('#editor-title').html ''
	clearStatus: ->
		$('.debug-status').addClass 'hidden'
		@status.cmd = @status.ctrl = @status.alt = @status.shift = false
	cleanAttributes: (el)->
		attributes = $.map el.attributes, (item)->
			item.name
		$.each attributes, (i, key)=>
			$(@).removeAttr(key)
	divsToPs: ->
		#transform divs to ps
		@saveSelection()
		$('#editor div').not('[name]').each ->
			el = $('<p>')
			el.html $(@).html()
			$(@).after(el)
			$(@).remove()
		@restoreSelection()
	showTooltip: ->
		$('#tooltip').removeClass 'hidden' unless @status.showToolpad
		@status.showTooltip = true
	hideTooltip: ->
		$('#tooltip').addClass 'hidden'
		@status.showTooltip = false
	setTooltipTop: (top)->
		$('#tooltip').css 'top', top
	updateTooltipStatus: (jqel)->
		['h1', 'h2', 'pre'].forEach (tag, i)->
			btn = $("#tooltip .left-panel li:nth-child(#{i+1})")
			if jqel.is tag
				btn.addClass 'toggled'
			else
				btn.removeClass 'toggled'
	detectToShowToolpad: ->
		sel = @selection()
		if sel.rangeCount > 0
			range = sel.getRangeAt 0
			if !range.collapsed || @getSelectedElement().is 'a'
				@saveSelection 'toolpad'
				@showToolpadOverSelection 'toolpad'
				@restoreSelection 'toolpad'
				@linkRange = @selection().getRangeAt 0
			else
				@hideToolpad()
	showToolpadOverSelection: (prefix='m')->
		$('#toolpad').removeClass 'hidden'
		startEl = $('#'+prefix+'Start')
		endEl = $('#'+prefix+'End')
		top = Math.min startEl.offset().top, endEl.offset().top
		left = ( startEl.offset().left + endEl.offset().left ) / 2
		$('#toolpad').css 'top', top - 35
		$('#toolpad').css 'left', left - 90
		el = @getSelectedElement()
		if el.is 'a'
			$('#toolpad input').val el.attr('href')
			@openLinkInput()

		@hideTooltip()
		@status.showToolpad = true
	hideToolpad: ->
		$('#toolpad').addClass 'hidden'
		$('#toolpad li:first-child').removeClass 'toggled'
		@lastLinkElement = null
		@linkRange = null
		$('#toolpad input').val ''
		@status.showToolpad = false
	openLinkInput: ->
		$('#toolpad li:first-child').addClass 'toggled'
		$('#toolpad input').focus()
	cancelLinkInput: ->
		$('#toolpad li:first-child').removeClass 'toggled'
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
			$('#editor').trigger 'newPostCallback'
	checkTitleEmpty: ->
		@status.titleEmpty = $('#editor-title').text() == '' || $('#editor-title').text() == @titlePromptMessage
	checkEmpty: ->
		@status.empty = $('#editor').text() == '' || $('#editor').text() == @promptMessage
	toggleFormatBlock: (jqel, tag)->
		if jqel.attr 'name'
			@saveSelection()
			if jqel.is tag
				newEl = $('<p>').html jqel.html()
				newEl.attr 'name', jqel.attr 'name'
				newEl.attr 'class', jqel.attr 'class'
				jqel.after(newEl)
				jqel.remove()
				@restoreSelection()
			else
				newEl = $("<#{tag}>").html jqel.html()
				newEl.attr 'name', jqel.attr 'name'
				newEl.attr 'class', jqel.attr 'class'
				jqel.after(newEl)
				jqel.remove()
				@restoreSelection()
		else
			document.execCommand('formatBlock', false, tag)
		
	## EVENT BINDINGS ##
	delegateEditorTooltipEvents: ()->
		$('#tooltip').delegate '.left-panel li:nth-child(1)', 'click', (e)=>
			@toggleFormatBlock $('.hovered'), 'h1'
			@updateTooltipStatus $('.hovered')
		$('#tooltip').delegate '.left-panel li:nth-child(2)', 'click', (e)=>
			@toggleFormatBlock $('.hovered'), 'h2'
			@updateTooltipStatus $('.hovered')
		$('#tooltip').delegate '.left-panel li:nth-child(3)', 'click', (e)=>
			@toggleFormatBlock $('.hovered'), 'pre'
			@updateTooltipStatus $('.hovered')
		$('#tooltip').delegate '.right-panel li:nth-child(1)', 'click', (e)=>
			$('#image-file').click()
		$('body').delegate '#tooltip', 'mouseleave', (e)=>
			@hideTooltip()
		$('body').delegate '.content', 'mouseleave', (e)=>
			@hideTooltip()
	delegateEditorToolpadEvents: ()->
		self = @
		$('body').delegate '#editor', 'mouseup', (e)=>
			setTimeout =>
				@detectToShowToolpad()
			, 0
		$('body').delegate '#editor', 'keydown', (e)=>
			if e.keyCode == 37 || e.keyCode == 38 || e.keyCode == 39 || e.keyCode == 40
				setTimeout =>
					@detectToShowToolpad()
				, 0
		# apply link URL
		$('#toolpad').delegate 'li:first-child', 'click', (e)->
			self.openLinkInput()
		.delegate 'input', 'keydown', (e)->
			if e.keyCode == 13
				if self.linkRange
					self.applyOrCancelUrl self.linkRange, $(@).val()
				self.hideToolpad()
		$('#toolpad').delegate '.cancel', 'click', (e)->
			self.cancelLinkInput()
			if self.linkRange
				node = self.linkRange.commonAncestorContainer
				if node.nodeType == 3
					node = $(node).parent('a')
					range = document.createRange()
					range.selectNode node[0]
					self.linkRange = range
				self.applyOrCancelUrl self.linkRange, '' unless $(@).val()
	delegateEditorEvents: ()->
		self = @
		$('#editor').delegate '> h1,h2,p,pre,code,figure', 'mousemove', (e)->
			return if self.status.empty || self.status.new
			$(@).addClass('hovered').siblings().removeClass('hovered')
			parentOffset = $(@).parent().offset()
			thisOffset = $(@).offset()
			height = $(@).outerHeight()

			self.updateTooltipStatus $(@)
			self.showTooltip()
			self.setTooltipTop thisOffset.top - parentOffset.top
		.delegate '> h1,h2,p,pre,code,figure', 'mouseleave', (e)->
			self.update()		
	handleTitleKeyDown: (e)->
		switch e.keyCode
			when 13
				e.preventDefault()
				e.stopPropagation()
	handleTitleKeyUp: (e)->
	handleKeyDown: (e)->
		# debug
		$('#debug-keydown').text e.keyCode

		switch e.keyCode
			when 49
				if @status.cmd or @status.ctrl
					@toggleFormatBlock @getSelectedElement(), 'h1'
					e.preventDefault()
					e.stopPropagation()
			when 50
				if @status.cmd or @status.ctrl
					@toggleFormatBlock @getSelectedElement(), 'h2'
					e.preventDefault()
					e.stopPropagation()
			when 51
				if @status.cmd or @status.ctrl
					@toggleFormatBlock @getSelectedElement(), 'pre'
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
				if $('#editor').html().match /^<(h1|h2|p|pre|code|figure) [^>]*><br><\/(h1|h2|p|pre|code|figure)>$/
					e.preventDefault()
					e.stopPropagation()

	handleKeyUp: (e)->
		# debug
		$('#debug-keyup').text e.keyCode
		switch e.keyCode
			when 13
				@divsToPs()
				jqel = @getSelectedElement()
				jqel.removeClass()
				@assignNameAttribute jqel
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

	bindEditorTitleEvents:->
		$('#editor-title').on 'keydown', (e)=>
			@handleTitleKeyDown(e)
		.on 'keyup', (e)=>
			@detectContentsChanged()
			@handleTitleKeyUp(e)
		.on 'paste', (e)=>
			self = @
			e.preventDefault()
			raw = e.clipboardData.getData('text/html') || e.clipboardData.getData('text')
			pasteElement = document.createElement 'p'
			pasteElement.innerHTML = raw
			$(pasteElement).find('*').each ->
				self.cleanAttributes @[0]
			document.execCommand 'insertHtml', false, $(pasteElement).text()
			@setChanged true
		.blur =>
			@updateTitlePrompt(false)
		.focus =>
			# prevent caret being eaten
			setTimeout =>
				@updateTitlePrompt(true)
			, 0

	bindAllEvents: ->
		$('#editor').on 'keydown', (e)=>
			@hideTooltip()
			@hideToolpad()
			@checkNew() if @status.new
			@handleKeyDown(e)
			@update()
		.on 'keyup', (e)=>
			@detectContentsChanged()
			@handleKeyUp(e)
			@update()
			@checkEmpty()
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
			@setChanged true
		.on 'newPostCallback', =>
			if @newPostCallback
				@newPostCallback( @ ) unless @status.connecting
			else
				@id = 'A00000'
		.blur =>
			@updatePrompt(false)
			@clearStatus()
		.focus (e)=>
			# prevent caret being eaten
			setTimeout =>
				@updatePrompt(true)
			, 0
			@update()
			@clearStatus()

		# dynamic events
		@delegateEditorEvents()
		@delegateEditorTooltipEvents()
		@delegateEditorToolpadEvents()