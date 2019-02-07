// import "phoenix_html"


import init_adimage from './pages/adimage'
import init_adentry from './pages/adentry'

import init_search from "./pages/search"
import init_submit from "./pages/submit"

import init_shop from "./pages/shop"

$(_ => {

  init_submit()
  init_search()

  init_adimage()
  init_adentry()

  init_shop()

  $('.js-load-notif').click(e => {
    e.preventDefault()
    $('.header-notifs').addClass("_active")

    $.get('/_notification', data => {
      $("#notifs").html(data)
    })
  })

  $('.js-hide-notif').click(e => {
    e.preventDefault()
    $('.header-notifs').removeClass("_active")
  })
})

