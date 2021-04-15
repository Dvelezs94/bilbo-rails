// Create new selector "Contains" which is not case sensitive
jQuery.expr[':'].Contains = function(a,i,m){
    return jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase())>=0;
};

$(document).on('turbolinks:load', function() {
  if ($("#searchMultimedia").length) {
    $("#searchMultimedia").on("input", function() {
      var inputText = $(this).val().toLowerCase();
      $('.mmtitle').closest('.mmcard').hide();
      $('.mmtitle:Contains("'+ inputText +'")').closest('.mmcard').show();
    });
  }
});

$(document).on('turbolinks:load', function() {
  if ($(".filter_content").length) {
    initialize_content_filter();
  }
});


function initialize_content_filter(){
  $(".filter_content").on("click", function(e) {
    e.preventDefault();
    const filt = $(e.currentTarget).attr("href").replace('#','');
    if (filt == "none") {
      $('.mmtitle').closest('.mmcard').show();
    } else {
      $('.mmtitle').closest('.mmcard').hide();
      $('[data-multimedia-type="' + filt + '"]').show()
    }
  });
}
