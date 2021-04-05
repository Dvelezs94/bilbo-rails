$(document).on('turbolinks:load', function() {
  // if ($(".board-ads").length) {
  if (true) {
    App.boards_display = App.cable.subscriptions.create({channel: "BoardsDisplayChannel", id: $("[data-board]").attr("data-board") }, {
      connected: function() {
        // Called when the subscription is ready for use on the server
      },
      disconnected: function () {
        // Called when the subscription has been terminated by the server
      },
      received: function(data) {
        // Called when the admin want reload the board
        if( data['action'] == "reload" ) {
        url = window.location.href;
        let searchParams = new URLSearchParams(window.location.search)
          if (searchParams.has('autoplay')){
            Turbolinks.visit(location.toString());
          } else {
            url += '&autoplay=true'
            window.location.href = url;
            Turbolinks.visit(location.toString());
          }
        }
        // Called when there's incoming data on the websocket for this channel
        if( data['action'] == "enable" ) {
          $('.board-ads').append(data['ad']);
        } else if (data['action'] == "disable") {
          $("[data-campaign="+ data["campaign_slug"] +"]").remove();
        }
        else if(data['action'] == "update_rotation"){
          //nothing custom
        }
        // ad rotation replacement
        $("#ads_rotation").val(data['ads_rotation']);
        console.log("Update received");
      }
    });
  }
});
