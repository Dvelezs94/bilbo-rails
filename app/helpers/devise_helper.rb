module DeviseHelper
  def devise_error_messages!
    messages = resource.errors.full_messages.map { |msg|
      String.new(" M.toast({html: '" + msg + "' }); ".html_safe )
    }.join

    messages = ("<script>" + messages + "</script>").html_safe
  end
end
