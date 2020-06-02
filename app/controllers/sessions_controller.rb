class SessionsController < Devise::SessionsController
  def create
    super
    flash[:success] = I18n.t('devise.sessions.signed_in')
  end

  # GET /resource/sign_out
  def destroy
    super
    flash[:success] = I18n.t('devise.sessions.signed_out')
  end
end
