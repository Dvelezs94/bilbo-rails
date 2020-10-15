// We need to keep this script at the top so the Action cable variable is created
(function() {
  this.App || (this.App = {});
  App.cable = ActionCable.createConsumer();
}).call(this);

// retry connections every 100 seconds if its disconnected
$(document).on('turbolinks:load', function() {
  setTimeout(function(){
    if (App.cable.connection.disconnected){
      App.cable.connection.reopen();
      console.log("connection reopened");
    }
  }, 100000);
});
