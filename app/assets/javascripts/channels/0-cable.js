// We need to keep this script at the top so the Action cable variable is created
(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();

}).call(this);