$(document).on('turbolinks:before-cache', function(){
  $("[id^=modal]").each(function(){
    if(!$(this).hasClass('show')) return; //skip already closed modals
    this.remove() //close the modal
  })
  $('body').removeClass('modal-open')
  $(".modal-backdrop").remove()
});
