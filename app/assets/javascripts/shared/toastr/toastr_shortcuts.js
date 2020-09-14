function show_notice(text, title = "", params = {}) {
  toastr.info(text, title, params);
}

function show_success(text, title = "", params = {}) {
  toastr.success(text, title, params);
}

function show_error(text, title = "", params = {}) {
  toastr.error(text, title, params);
}
