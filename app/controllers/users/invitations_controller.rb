class Users::InvitationsController < Devise::InvitationsController
  before_action :have_a_user_invitation?, only: [:create, :update]
  # GET /resource/invitation/new
  def new
    super
  end

  # POST /resource/invitation
  def create
    super
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    super
  end

  # PUT /resource/invitation
  def update
    super
  end

  # GET /resource/invitation/remove?invitation_token=abcdef
  def destroy
    super
  end

  protected

    def invite_params
      devise_parameter_sanitizer.permit(:invite, keys: [:role, :name, :project_name])
      devise_parameter_sanitizer.sanitize(:invite)
    end

    def update_resource_params
      devise_parameter_sanitizer.permit(:accept_invitation, keys: [:role, :name, :project_name])
      devise_parameter_sanitizer.sanitize(:accept_invitation)
    end

  def have_a_user_invitation?
    if invite_params[:role] == "provider" && User.find_by(email: invite_params[:email]).present? && User.find_by(email: invite_params[:email]).invitation_created_at.present?
      flash[:error] = I18n.t('projects.user_has_an_invitation')
      redirect_to root_path
    end
  end
end
