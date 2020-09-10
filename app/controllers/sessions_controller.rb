class SessionsController < Devise::SessionsController
  protect_from_forgery prepend: true

  def create
    super
  end

  # GET /resource/sign_out
  def destroy
    super
  end

protected

  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.banned?
      sign_out resource
      flash[:error] = "This account has been suspended"
      root_path
    else
      super
    end
  end

end