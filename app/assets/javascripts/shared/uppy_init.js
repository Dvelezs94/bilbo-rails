function init_uppy() {
  var create_attachment_url = document.location.protocol +"//"+ document.location.hostname + "/contents/create_multimedia";
  const ProgressBar = Uppy.ProgressBar
  const FileInput = Uppy.FileInput
  var uppy = Uppy.Core({
    restrictions: {
      maxFileSize: 20971520,
      maxNumberOfFiles: 3,
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
      fieldName: 'multimedia',
      getResponseData (responseText, response) {
        return {
          responseBody: responseText
        }
      }
      // bundle: false,
      // timeout: 0
    })
    // uppy.use(Uppy.Dropbox, { target: Uppy.Dashboard, companionUrl: 'https://companion.uppy.io' })
    // uppy.use(Uppy.GoogleDrive, { target: Uppy.Dashboard, companionUrl: 'https://companion.uppy.io' })
    // uppy.use(Uppy.Webcam, { target: Uppy.Dashboard, companionUrl: 'https://companion.uppy.io' })
    uppy.on('upload-success', (file, res) => {
      eval(res.body.responseBody);
    })

    uppy.on('complete', (result) => {
      $("#modalNewMultimedia").modal('hide');
    })

    uppy.on('upload-error', (file, error, response) => {
      show_error(error);
    })
}
