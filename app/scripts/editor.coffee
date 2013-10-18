$(document).ready ->
	update = ->
		console.log '123'
		$('#debug').text $('#editor').html()
	
	# init
	update()

	# binding
	$('#editor').on 'keyup', ->
		update()