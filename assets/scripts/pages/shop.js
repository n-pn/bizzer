export default function init() {
  var $cover_input = $('#shop_cover_input')
  var $cover_output = $('#shop_cover_output')
  var $cover_preview = $('#shop_cover_preview')

  var $avatar_input = $('#shop_avatar_input')
  var $avatar_output = $('#shop_avatar_output')
  var $avatar_preview = $('#shop_avatar_preview')

  $cover_input.change(e => {
    upload_image($cover_input, $cover_output, $cover_preview, 'cover')
  })

  $avatar_input.change(e => {
    upload_image($avatar_input, $avatar_output, $avatar_preview, 'avatar')
  })

  var $shop_popup =$('#shop_popup')

  $('.js-show-shop-popup').click(e => {
    e.preventDefault();
    $shop_popup.addClass('_active');
  })

  $('.js-hide-shop-popup').click(e => {
    e.preventDefault();
    $shop_popup.removeClass('_active');
  })
}

function upload_image(input_elem, output_elem, preview_elem, type) {
  var fd = new FormData()
  fd.append('upload_file', input_elem[0].files[0])
  fd.append('_csrf_token', $('[name="_csrf_token"]').val())

  $.ajax({
    url: '/_upload/' + type,
    data: fd,
    processData: false,
    contentType: false,
    type: 'POST',
    success: function (data) {
      input_elem.val("")
      output_elem.val(data.file_path)
      preview_elem.attr("src", data.file_path).attr("alt", data.file_name)
    }
  })
}
