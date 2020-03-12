class Projects::ProjectUsersController < ApplicationController
  access user: :all
  before_action :validate_owner

  def create
    project_user = @project.project_users.new(project_user_params)

    if project_user.save
      flash[:success] = I18n.t('projects.member_invited')
    else
      flash[:error] = I18n.t('projects.member_invited_error')
    end
    redirect_to root_url(subdomain: @project.slug)
  end

  def destroy
    @project_user = ProjectUser.where(project: @project, user_id: params[:id])
    if @project_user.destroy_all
      flash[:success] = I18n.t('projects.member_deleted')
    else
      flash[:error] = I18n.t('projects.member_deletion_error')
    end
    redirect_to root_path
  end

  private
  def project_user_params
    params.require(:project_user).permit(:email, :role)
  end

  def validate_owner
    raise_not_found if not @project.owners.include? current_user.id
  end
end
