class Projects::ProjectUsersController < ApplicationController
  access user: :all
  before_action :set_current_project
  before_action :validate_admins
  before_action :avoid_owner_deletion, only: :destroy

  def create
    project_user = @current_project.project_users.new(project_user_params)

    if project_user.save
      flash[:success] = I18n.t('projects.member_invited')
    else
      flash[:error] = I18n.t('projects.member_invited_error')
    end
    redirect_to root_url(subdomain: @current_project.slug)
  end

  def destroy
    @project_user = ProjectUser.where(project: @current_project, user_id: params[:id])
    if @project_user.destroy_all
      flash[:success] = I18n.t('projects.member_deleted')
    else
      flash[:error] = I18n.t('projects.member_deletion_error')
    end
    # if admin removes himself from project, redirect to other project
    if params[:id].to_i == current_user.id
      puts "x" * 500
      redirect_to root_url(subdomain: current_user.projects.first.slug)
    else
      redirect_to root_path
    end
  end

  private
  def project_user_params
    params.require(:project_user).permit(:email, :role)
  end

  def set_current_project
    @current_project = current_user.projects.friendly.find(params[:project_id])
  end

  def validate_admins
    raise_not_found if not @current_project.admin? current_user.id
  end

  def avoid_owner_deletion
    raise_not_found if @current_project.owned?(params[:id].to_i)
  end
end
