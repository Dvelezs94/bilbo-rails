class SessionsController < Devise::SessionsController
  protect_from_forgery prepend: true

  def create
    super
  end

  # GET /resource/sign_out
  def destroy
    super
  end
end
