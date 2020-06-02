class PasswordsController < Devise::PasswordsController
  protected
  def after_sending_reset_password_instructions_path_for(resource_name)
    flash[:success] = I18n.t('devise.passwords.send_instructions')
      new_session_path(resource_name) if is_navigational_format?
  end
end
