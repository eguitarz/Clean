(function() {
  $('#editor').on('keyup', function() {
    return $('#debug').text($('#editor').html());
  });

}).call(this);
