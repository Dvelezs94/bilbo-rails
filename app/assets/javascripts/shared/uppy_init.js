$(document).on('turbolinks:load', function() {
  if ($("#drag-drop-area").length) {
    var create_attachment_url = document.location.protocol +"//"+ document.location.hostname + document.location.pathname + "/attachments";
    const ProgressBar = Uppy.ProgressBar
    var uppy = Uppy.Core({
      restrictions: {
        maxFileSize: 55000000,
        allowedFileTypes: ["image/png", "image/jpeg", "video/mp4", "video/x-msvideo", "video/msvideo", "video/avi", "video/vnd.avi"]
      }
    })
    .use(Uppy.Dashboard, {
      inline: true,
      target: '#drag-drop-area',
    })
    .use(Uppy.XHRUpload, {
      endpoint: create_attachment_url,
      bundle: true
    })
    // uppy.use(Uppy.Dropbox, { target: Uppy.Dashboard, companionUrl: 'https://companion.uppy.io' })
    // uppy.use(Uppy.GoogleDrive, { target: Uppy.Dashboard, companionUrl: 'https://companion.uppy.io' })
    // uppy.use(Uppy.Webcam, { target: Uppy.Dashboard, companionUrl: 'https://companion.uppy.io' })

    uppy.on('complete', (result) => {
      setTimeout(function(){
        if ($.urlParam('campaign_ref')) {
          document.location.href = '/campaigns/' + $.urlParam('campaign_ref') + "/edit"
        } else {
          location.reload();
        }
      }, 2000);
    })

    uppy.on('upload-error', (file, error, response) => {
      show_error("Make sure you have all ad blockers disabled");
    })
  }
});
