function get_position(e) {
  var offset = $(e.currentTarget).offset()

  var x_offset = Math.round(e.pageX - offset.left - 75)
  var y_offset = Math.round(e.pageY - offset.top - 30)

  return { x_offset, y_offset }
}

export default () => {
  var $adimage_wrap = $('.adimage-wrap')

  $adimage_wrap.on('mousemove', e => {
    var { x_offset, y_offset } = get_position(e)
    $(e.currentTarget).children('.adimage-overlay').css({ "left": x_offset, "top": y_offset }).addClass("_active")
  })

  $adimage_wrap.on('mouseleave', e => {
    $(e.currentTarget).children('.adimage-overlay').removeClass("_active")
  })

  $adimage_wrap.click(e => {
    clearTimeout()

    var { x_offset, y_offset } = get_position(e)
    var $this = $(e.currentTarget)
    var adimage_id = $this.data('adimage')
    var link = `/quan-ly/file-anh/${adimage_id}/chen-logo/${x_offset}/${y_offset}`

    $this.addClass('_loading')

    $.getJSON(link, data => {
      console.log(data)
      $this.children('.adimage-image')
        .attr('src', data.url)
        .on('load', _ => {
          $this.removeClass('_loading')
          setTimeout(() => { window.location.href = '/quan-ly/file-anh/chon-anh' }, 100);
        })

    }).fail(data => {
      console.log(data)
      $this.removeClass('_loading')
      $this.parent().children('.adimage-meta').html(data.msg)
    })
  })
}
