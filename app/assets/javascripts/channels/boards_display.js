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
        // Called when the admin want reload the board
        if( data['action'] == "reload" ) {
          window.location.reload();
        }

        if(data['action'] == "delete_default_content" ) {
          $("#default-content-" + data['ad']).remove();
          console.log("Update content default received");
        }

        if(data['action'] == "update_default_content" ) {
        $(data['ad']).each(function() {
          if($("#"+$(this).attr('id')).length == 0) {
            $('#bilbo-ad').append($(this));
            console.log("Update content default received");
          }
          });
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

        if(data['action'] != "update_default_content" && data['action'] != "delete_default_content" ){
          // ad rotation replacement
          $("#ads_rotation").val(data['ads_rotation']);
          console.log("Update received");
        }
      }
    });
  }
});
