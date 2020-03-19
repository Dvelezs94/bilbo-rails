//= require rails-ujs
//= require activestorage
//= require turbolinks

//= require jquery3
//= require popper
//= require bootstrap
//= require toastr
//= require jquery.steps
//= require jquery-ui
//= require clipboard
//= require data-confirm-modal
//= require jquery-ui/widgets/autocomplete
//= require autocomplete-rails
//= require chartkick

//= require_tree ./global_dependencies


$(document).on('turbolinks:fetch', function(){
  $("#p1").removeClass("d-none");
  $(".content").hide();
  $(".spinner").show();
});

$(document).on("turbolinks:receive", function(){
  $("#p1").addClass("d-none");
  $(".spinner").hide();
  $(".content").show();
});
