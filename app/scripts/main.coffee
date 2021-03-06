'use strict'
@Clean = @Clean || {}

@Clean.editor = new Editor 
  newPostCallback: (editor)->
    editor.setConnecting true
    $.ajax
      url: 'http://localhost:3000'
      success: (data)->
        console.log 'ask id success'
        editor.id = 'MOCKID123'
        editor.setConnecting false
      error: ->
        console.log 'unable to ask id'
        editor.setConnecting false
  autosaveCallback: (editor)->
    editor.setConnecting true
    $('#server-status').text 'Saving...'
    $.ajax
      url: 'http://localhost:3000'
      success: (data)->
        console.log 'autosave success'
        editor.setConnecting false
        setTimeout ->
          $('#server-status').text 'Saved'
          setTimeout ->
            $('#server-status').text ''
          , 3000
        , 500
      error: ->
        $('#server-status').text ''
        console.log 'unable to autosave'
        editor.setConnecting false
  imageCallback: (editor)->
    editor.setConnecting true
    $.ajax
      url: 'http://localhost:3000'
      success: (data)->
        console.log 'image upload success'
        editor.setConnecting false
        # append image to editor
          $('.hovered').append('<figure><img src="'+data+'"></figure>')

        setTimeout ->
          $('#server-status').text 'Saved'
          setTimeout ->
            $('#server-status').text ''
          , 3000
        , 500

$(document).ready =>
  @Clean.editor.init()