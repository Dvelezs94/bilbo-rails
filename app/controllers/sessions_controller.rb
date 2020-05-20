class SessionsController < Devise::SessionsController
  def create
    super
  end

  # GET /resource/sign_out
  def destroy
    super
  end
end
