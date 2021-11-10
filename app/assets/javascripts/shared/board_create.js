$(document).on('turbolinks:load', function () {
  if ($('#new_board').length) {
    fields = ["#board_extra_percentage_earnings", "#board_name", "#board_address", "#board_lat", "#board_lng", "#board_utc_offset", "#board_category", "#board_avg_daily_views", "#board_displays_number",
              "#board_provider_earnings", "#board_base_earnings", "#board_face", "#board_social_class", "#board_width", "#board_height", "#board_start_time", "#board_end_time", "#board_duration", "#board_images",
              "#board_default_images", "#board_country", "#board_country_state", "#board_city", "#board_postal_code"]
    form_sections = ["#name", "#address", "#info", "#expectedProfit", "#face", "#socialClass", "#dimensions", "#activeTime", "#imagesOnly", "#macAddr", "#images_section", "#defaultImages", "#integrations"]

    updateForm();
    $("#csv").click(updateForm);
    // Change the form according to the csv checkbox (show the required fields)
    function updateForm(){
      if (!$("#csv").is(':checked') && $("#board_upload_from_csv").length) { // Disable field
        $("#board_upload_from_csv").prop('style').display = "none"
        form_sections.forEach((item, i) => {
          $(item).prop('style').display = "";
        });
      } else if($("#board_upload_from_csv").length){
        $("#board_upload_from_csv").prop('style').display = ""
        form_sections.forEach((item, i) => {
          $(item).prop('style').display = "none";
        });
      }
      toggleRequiredFields();
    }

    // Set which fields are required according to the upload mode
    function toggleRequiredFields() {
      var mode = $("#csv").is(':checked');
      $("#board_upload_from_csv").prop('required', mode);
      fields.forEach((item, i) => {
        $(item).prop('required', !mode)
      });
    }
  }
});
