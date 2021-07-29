$(document).on('turbolinks:load', function() {
  window.price_slider = $("#price_slider").ionRangeSlider({
        type: "double",
        min: 0,
        max: 500,
        from: 0,
        to: 500,
        step: 1,
        grid: true,
        skin: "round",
        prefix: "$",
        onStart: function (data) {
          $("#cycle_price_min").val(data.from);
          $("#cycle_price").val(data.to);
        },
        onFinish: function (data) {
            // Called then action is done and mouse is released
            $("#cycle_price_min").val(data.from);
            $("#cycle_price").val(data.to);
            $("#cycle_price_min").trigger("change"); //triggers change so the filter is sent
        }
    });
  window.price_slider = window.price_slider.data('ionRangeSlider');

  $("#cycle_price_min").on("change", function(){
    // validate
    min = window.price_slider.options.min;
    max = window.price_slider.options.max;
    from_val = this.value;
    to_val = $("#cycle_price").val();
    if (from_val < min) {
        from_val = min;
    } else if (from_val > to_val) {
        from_val = to_val;
    } else if (from_val > max){
        from_val = max;
    }
    window.price_slider.update({from: from_val});
    this.value = from_val;
  });
  $("#cycle_price").on("change", function(){
    // validate
    min = window.price_slider.options.min;
    max = window.price_slider.options.max;
    from_val = $("#cycle_price_min").val();
    to_val = this.value;
    if (to_val > max) {
        to_val = max;
    } else if (from_val > to_val) {
        to_val = from_val;
    } else if (to_val < min){
        to_val = min;
    }
    window.price_slider.update({to: to_val});
    this.value = to_val;
  });
});
