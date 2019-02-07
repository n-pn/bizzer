import 'slick-carousel'

export default function init() {

  $("#adentry-images").slick({
    infinite: true,
    slidesToShow: 1,
    dots: true,
    speed: 250,
    centerMode: true,
    variableWidth: true,
    adaptiveHeight: true
  })

  $('.js-share-facebook').click(function (e) {
    e.preventDefault()

    FB.ui({
      method: 'share',
      display: 'popup',
      href: e.currentTarget.dataset.href,
    }, function (response) { });
  })

  $('.js-share-sms').click(function (e) {
    if (getMobileOperatingSystem() == 'iOS') {
      var $this = $(e.currentTarget)
      var href = $this.attr('href')
      href = href.replace('?body=', '&body=')
      $this.attr('href', href)
    }

    return true
  })

  $('.js-copy-link').click(e => {
    e.preventDefault()
    var href = e.currentTarget.href
    var $temp = $('<input>')
    $("body").append($temp)
    $temp.val(href).select()
    document.execCommand("copy")
    $temp.remove()

    var $hint = $('<span class="share-hint">Đã copy link</span>')
    $('.adentry-share').append($hint)
    setTimeout(_ => { $hint.remove() }, 800)

  })
}


function getMobileOperatingSystem() {
  var userAgent = navigator.userAgent || navigator.vendor || window.opera;

  if ( userAgent.match( /iPad/i ) || userAgent.match( /iPhone/i ) || userAgent.match( /iPod/i ) ) { return 'iOS'; }

  else if ( userAgent.match( /Android/i ) ) { return 'Android'; }

  else { return 'unknown'; }
}
