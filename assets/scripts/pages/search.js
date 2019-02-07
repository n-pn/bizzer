export default () => {
  $('.js-show-filter').click(e => {
    e.preventDefault()
    $('#filter-' + e.currentTarget.dataset.fid).addClass('_active')
  })

  $('.js-hide-filter').click(e => {
    e.preventDefault()
    $('#filter-' + e.currentTarget.dataset.fid).removeClass('_active')
  })

  $('.js-show-filter-child').click(e => {
    e.preventDefault()
    $('#filter-' + e.currentTarget.dataset.fid).addClass('_onchild').find('.filter-child').removeClass('_active')
    $('#filter-' + e.currentTarget.dataset.cid).addClass('_active')
  })

  $('.js-show-filter-parent').click(e => {
    e.preventDefault()
    $('#filter-' + e.currentTarget.dataset.fid).removeClass('_onchild').find('.filter-child').removeClass('_active')
  })


  $('.js-update-filter').click(e => {
    e.preventDefault()

    var $this = $(e.currentTarget)
    var input = $this.data('input')

    $(`[data-input="${input}"]`).removeClass('_active')
    $this.addClass('_active')

    $(`#filter-${input}-value`).val($this.data('value'))
    $(`#filter-${input}-print`).html($this.data('print')).removeClass('_empty')

    $(`.propkey-${$this.data('propkey')}`).addClass('_hide')
    $(`.propval-${$this.data('propval')}`).removeClass('_hide')

    $('#filter-' + $this.data('fid')).removeClass('_onchild').find('.filter-child').removeClass('_active')
  })

  $('.js-reset-filter').click(e => {
    e.preventDefault()
    $('.filter input').val("")
    $('.filter-print').each(function () {
      var $el = $(this)
      $el.html($el.data('placeholder')).addClass('_empty')
    })
  })

  // $('.js-apply-filter').click(e => {
  //   $('input').each(_ => {
  //     if ($this.val() == "") $this.remove();
  //   })
  //   e.preventDefault()
  //   return true;
  // })

  // $("#query-form").submit(function () {
  //   $(this).children('input[value=""]').remove();
  //   return true; // ensure form still submits
  // });
}
