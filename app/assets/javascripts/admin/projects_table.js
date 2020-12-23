function send_info(button){
  event.preventDefault();
  row = $(button).closest("tr").clone();
  form = $("#form_for_projects");
  form.attr("action",$(button).attr("url"));
  form.find("tr").remove();
  form.append(row);
  form.submit();
}
