function clear_notifications(){
  event.preventDefault();
  if($("#notifCount")[0] != undefined){
    $("#notifCount")[0].outerText= ""
    form = $("#clear-notif");
    form.submit();
  }
};
