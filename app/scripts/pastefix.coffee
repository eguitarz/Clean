$.event.fix = ((originalFix) ->
  (event) ->
    event = originalFix.apply(this, arguments)

    if event.type.indexOf('copy') == 0 || event.type.indexOf('paste') == 0
      event.clipboardData = event.originalEvent.clipboardData

    return event

)($.event.fix)