$(document).ready(function() {
  if ($('#landingNavLinks').length > 0) {
    $('body').scrollspy({target: '#landingNavLinks', offset: 56});
  }
});
