$(function() {
  // Fix input element click problem
  $('.dropdown-menu form').on('click', function(e) {
    e.stopPropagation();
  });
  $('.dropdown-menu').on('touchstart.dropdown.data-api', function(e) {
    e.stopPropagation()
  })

  // Instantiate Twitter Combobox plugin
  $('.combobox').combobox({
    clearIfNoMatch: false,
    bsVersion: '4',
    iconCaret: 'dropdown-toggle'
  });

  // Select default address
  const $address = $("#address");
  $address[0].setSelectionRange(0, $address.val().length);
});

