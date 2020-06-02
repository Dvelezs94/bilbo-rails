class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)

   resource.save
   flash[:success] = I18n.t('devise.registrations.signed_up_but_unconfirmed')
   yield resource if block_given?
   if resource.persisted?
     if resource.active_for_authentication?
       flash[:success] = :signed_up
       set_flash_message! :notice, :signed_up
       sign_up(resource_name, resource)
       respond_with resource, location: after_sign_up_path_for(resource)
     else
       set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
       expire_data_after_sign_in!
       respond_with resource, location: after_inactive_sign_up_path_for(resource)
     end
   else
     clean_up_passwords resource
     set_minimum_password_length
     respond_with resource
   end

  end
  protected

  def update_resource(resource, params)
    # Require current password if user is trying to change password.
    return super if params["password"]&.present?

    # Allows user to update registration information without password.
    resource.update_without_password(params.except("current_password"))
  end

  def after_update_path_for(resource)
      edit_user_registration_path
  end
end
