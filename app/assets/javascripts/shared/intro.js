$(document).on('turbolinks:load', function() {
  $("#launch_wizard").click(function(e){
    introJs().setOptions({
      steps:[
        {
          intro: $("#launch_wizard").attr("data-intro")
        },
        {
          intro: $("#campaignLink").attr("data-intro"),
          element: $("#campaignLink")[0]
        },
        {
          intro: $("#adLink").attr("data-intro"),
          element: $("#adLink")[0]
        },
        {
          intro: $("#boardLink").attr("data-intro"),
          element: $("#boardLink")[0]
        },
        {
          intro: $("#teamMenuButton").attr("data-intro"),
          element: $("#teamMenuButton")[0]
        },
        {
          intro: $("#introBalance").attr("data-intro"),
          element: $("#introBalance")[0]
        },
        {
          intro: $("#notifBell").attr("data-intro"),
          element: $("#notifBell")[0]
        },
        {
          intro: $("#userDropdownImage").attr("data-intro"),
          element: $("#userDropdownImage")[0]
        },
        {
          intro: $("#helpLink").attr("data-intro"),
          element: $("#helpLink")[0]
        }
      ],
      showStepNumbers: false,
      nextLabel: '→',
      prevLabel: '←',
      skipLabel: $("#introJSskipLabel").attr("data-intro"),
      doneLabel: $("#introJSdoneLabel").attr("data-intro")
    }).start();
  });
});
