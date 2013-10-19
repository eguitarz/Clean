$(document).ready ->
	update = ->
		$('#debug').text $('#editor').html()
	
	# init
	update()

	# binding
	$('#editor').on 'keyup', ->
		update()