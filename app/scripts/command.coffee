@Command = class Command
	constructor: (@name, @val)->

	run: ->
		document.execCommand(@name, false, @val)