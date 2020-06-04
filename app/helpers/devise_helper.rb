module DeviseHelper
  def devise_error_messages!
    if resource.errors.full_messages.any?
        flash[:error] = resource.errors.full_messages.join(' & ')
    end
    return ''
  end
end
