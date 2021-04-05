// Return true if user is signed in
function user_signed_in() {
  if (getCookie("signed_in") == 1) {
    return true;
  } else {
    return false
  }
}
