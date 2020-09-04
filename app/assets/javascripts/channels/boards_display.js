$(document).on('turbolinks:load', function() {
  if ($(".board-ads").length) {
    App.boards_display = App.cable.subscriptions.create({channel: "BoardsDisplayChannel", id: $("[data-board]").attr("data-board") }, {
      connected: function() {
        // Called when the subscription is ready for use on the server
      },
      disconnected: function () {
        // Called when the subscription has been terminated by the server
      },
      received: function(data) {
        // Called when there's incoming data on the websocket for this channel
        if( data['action'] == "enable" ) {
          $('.board-ads').append(data['ad']);
        } else {
          $("[data-campaign="+ data["campaign_slug"] +"]").remove();
        }
        // ad rotation replacement
        $("#ads_rotation").val(data['ads_rotation']);
        console.log("Update received");
      }
    });
  }
});
