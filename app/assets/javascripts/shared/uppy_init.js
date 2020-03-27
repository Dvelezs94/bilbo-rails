$(document).on('turbolinks:load', function() {
  if ($("#drag-drop-area").length) {
    var create_attachment_url = window.location.href + "/attachments";
    var uppy = Uppy.Core({
      restrictions: {
        maxFileSize: 10000000,
        allowedFileTypes: ["image/png", "image/jpeg", "image/gif"]
      }
    })
    .use(Uppy.Dashboard, {
      inline: true,
      target: '#drag-drop-area',
    })
    .use(Uppy.XHRUpload, {
      endpoint: create_attachment_url
    })
    // uppy.use(Uppy.Dropbox, { target: Uppy.Dashboard, companionUrl: 'https://companion.uppy.io' })
    // uppy.use(Uppy.GoogleDrive, { target: Uppy.Dashboard, companionUrl: 'https://companion.uppy.io' })
    // uppy.use(Uppy.Webcam, { target: Uppy.Dashboard, companionUrl: 'https://companion.uppy.io' })

    uppy.on('upload-success', (result) => {
      setTimeout(function(){
        location.reload();
      }, 2000);
    })

    uppy.on('upload-error', (file, error, response) => {
      show_error("Make sure you have all ad blockers disabled");
    })
  }
});
