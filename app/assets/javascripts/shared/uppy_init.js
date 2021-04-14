$(document).on('turbolinks:load', function() {
  if ($("#drag-drop-area").length) {
    var create_attachment_url = document.location.protocol +"//"+ document.location.hostname + document.location.pathname + "/attachments";
    const ProgressBar = Uppy.ProgressBar
    var uppy = Uppy.Core({
      restrictions: {
        maxFileSize: 20971520,
        allowedFileTypes: ["image/png", "image/jpeg", "video/mp4"]
      }
    })
    .use(Uppy.Dashboard, {
      inline: true,
      target: '#drag-drop-area',
      showProgressDetails: false
    })
    .use(Uppy.XHRUpload, {
      endpoint: create_attachment_url,
      bundle: true,
      timeout: 0
    })
    // uppy.use(Uppy.Dropbox, { target: Uppy.Dashboard, companionUrl: 'https://companion.uppy.io' })
    // uppy.use(Uppy.GoogleDrive, { target: Uppy.Dashboard, companionUrl: 'https://companion.uppy.io' })
    // uppy.use(Uppy.Webcam, { target: Uppy.Dashboard, companionUrl: 'https://companion.uppy.io' })

    uppy.on('complete', (result) => {
      setTimeout(function(){
        if ($.urlParam('campaign_ref')) {
          if ($.urlParam('gtm_wizard_upload_ad_create')) {
            document.location.href = '/campaigns/' + $.urlParam('campaign_ref') + "/edit?gtm_campaign_create=true"
          } else if ($.urlParam('gtm_wizard_upload_ad_edit')) {
            document.location.href = '/campaigns/' + $.urlParam('campaign_ref') + "/edit?gtm_campaign_edit=true"
          } else {
            document.location.href = '/campaigns/' + $.urlParam('campaign_ref') + "/edit"
          }
        } else {
          location.reload();
        }
      }, 2000);
    })

    uppy.on('upload-error', (file, error, response) => {
      show_error(error);
    })
  }
});
