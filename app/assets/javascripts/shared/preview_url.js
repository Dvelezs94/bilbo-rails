function preview(){
  console.log("I was here");
    if(input = $("#content_url").length){
      console.log("entre")
    input = $("#content_url");
    $("#content_url").on("paste", function(){
      setTimeout(function() {
      console.log("salud");
      console.log("attr: " + input.val());
      console.log($("#iframe-modal").attr("src", $("#content_url").val()));
      //$('#imagw').html('<iframe src="'+$("#content_url").val()+'" />')
      //console.log(input.val())
      //console.log($("#iframe-modal"))
      }, 500);
    });
  }
}
