// Create new selector "Contains" which is not case sensitive
jQuery.expr[':'].Contains = function(a,i,m){
    return jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase())>=0;
};

$(document).on('turbolinks:load', function() {
  if ($("#searchMultimedia").length) {
    $("#searchMultimedia").on("input", function() {
      var inputText = $(this).val().toLowerCase();
      $('.mmcard').hide();
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
    $(".filter_content.nav-link.active").removeClass("active");
    $(e.currentTarget).addClass("active");
    const filt = $(e.currentTarget).attr("href").replace('#','');
    if (filt == "none") {
      $('.mmcard').show();
    } else {
      $('.mmcard').hide();
      $('[data-multimedia-type="' + filt + '"]').show()
    }
  });
}
