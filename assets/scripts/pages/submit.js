export default function init() {

  $('.submit').on('click', '.js-show-wizard', e => {
    e.preventDefault()
    showWizard($(e.currentTarget).data('wid'))
  })

  $('.submit').on('click', '.js-hide-wizard', e => {
    e.preventDefault()
    $('.wizard').removeClass('_active')
  })

  $('.submit').on('click', '.js-show-wizard-child', e => {
    e.preventDefault()
    var $this = $(e.currentTarget)

    $('#wizard-' + $this.data('wid')).addClass('_onchild').find('.wizard-child-content').removeClass('_active')
    $('#wizard-child-' + $this.data('cid')).addClass('_active')
  })

  $('.submit').on('click', '.js-show-wizard-parent', e => {
    e.preventDefault()
    var $this = $(e.currentTarget)
    $('#wizard-' + $this.data('wid')).removeClass('_onchild')
  })

  $('.wizard-input._price').on("keydown", e => {
    if (e.keyCode === 13) {
      e.preventDefault()
    }
  })


  $('.submit').on('click', '.js-update-output', e => {
    e.preventDefault()
    const $this = $(e.currentTarget)

    $('#wizard-' + $this.data('wid')).find('.js-update-output').removeClass('_active')
    $this.addClass('_active')

    const input = $this.data('input')

    $(`#output-${input}-value`).val($this.data('value'))
    $(`#output-${input}-print`).html($this.data('print')).removeClass('_empty')
    $(`#output-${input}-error`).html("")

    if (input == 'grouping') {
      changeProperties($this.data('value'))
    } else if (input.startsWith('propkey')) {
      $(`.propkey-${$this.data('propkey')}`).addClass('_hide')
      $(`.propval-${$this.data('propval')}`).removeClass('_hide')
    }

    showWizard($this.data('wid') + 1)
  })

  $('.js-change-output').change(e => {
    var $this = $(e.currentTarget)
    var input = $this.data('input')

    var value = $this.val()
    var print = value

    switch (input) {
      case 'details': case 'payment':
        print = renderHtml(value)
        break

      case 'price':
        print = renderPrice(value)
        break
    }

    $(`#output-${input}-value`).val(value)
    $(`#output-${input}-print`).html(print).removeClass('_empty')
    $(`#output-${input}-error`).html("")
  })


  $('.js-upload-image').change(e => {
    e.preventDefault()

    var fd = new FormData()
    fd.append('upload_file', $('#upload-file')[0].files[0])
    fd.append('_csrf_token', $('[name="_csrf_token"]').val())

    $.ajax({
      url: '/_upload/adimage',
      data: fd,
      processData: false,
      contentType: false,
      type: 'POST',
      success: function (data) {
        $('.js-upload-image').val("")

        var wizard_image = `
          <div class="wizard-image" data-image="${data.file_name}">
            <img src="${data.file_path}" alt="${data.file_name}">
            <button type="button" class="wizard-image-icon js-remove-image" data-image="${data.file_name}"><i class="icon fe fe-x"></i></button>
          </div>
          `
        $('#wizard-images').append(wizard_image)

        var output_value = `
          <input type="hidden" name="submit[image_urls][]" value="${data.file_path}" data-image="${data.file_name}">
        `
        $('#output-images-value').append(output_value)

        var output_print = `
          <img class="output-image" src="${data.file_path}" alt="${data.file_name}" data-image="${data.file_name}">
        `

        $('#output-images-print').append(output_print)
      }
    })
  })

  $('.wizard').on('click', '.js-remove-image', e => {
    var $this = $(e.currentTarget)
    var image = $this.data('image')
    $(`[data-image="${image}"]`).remove()
  })
}

function showWizard(wid) {
  $('.wizard').removeClass('_active')
  $('#wizard-' + wid).addClass('_active').find('.wizard-input').focus()
}

function changeProperties(grouping) {
  const link = '/_wizard/properties/' + grouping
  $.get(link, (data) => { $('#submit-properties').html(data) })
}

function renderPrice(input) {
  return parseInt(input).toLocaleString("vi-VN", { style: "currency", currency: "VND" })
}

function renderHtml(input) {
  return input.split("\n\n").map(el => {
    el = escapeHtml(el).split("\n").join("<br/>")
    return `<p>${el}</p>`
  }).join("")
}

function escapeHtml(unsafe) {
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}
