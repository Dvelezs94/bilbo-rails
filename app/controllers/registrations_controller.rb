class RegistrationsController < Devise::RegistrationsController
  # we use phone number field as captcha
  invisible_captcha only: [:create], honeypot: :phone_number, scope: "user"

  protected
  def update_resource(resource, params)
    puts resource
    # Require current password if user is trying to change password.
    return super if params["password"]&.present?

    # Allows user to update registration information without password.
    resource.update_without_password(params.except("current_password"))
  end

  def after_update_path_for(resource)
      request.referer
  end
end
