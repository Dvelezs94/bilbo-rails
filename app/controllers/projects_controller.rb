class ProjectsController < ApplicationController
  access user: :all
  before_action :set_current_project, only: :destroy
  before_action :verify_identity, only: [:update]
  before_action :validate_owner, only: :destroy
  before_action :validate_project_count, only: :destroy

  def index
    @projects = current_user.projects.includes(:project_users, :campaigns, :ads).enabled
  end

  def create
    @new_project = Project.new(project_params)
    @new_project.project_users.new(user: current_user, role: "owner")

    if @new_project.save
      flash[:success] = I18n.t('projects.successfully_created')
    else
      flash[:error] = I18n.t('error.error_ocurrred')
    end
    change_project_cookie(@new_project.slug)
    redirect_to root_url()
  end

  def destroy
    # attempt to stop all campaigns before deleting (disabling) the project
    if @current_project.campaigns.update_all(state: false)
      @current_project.update(status: "disabled")
      respond_to do |format|
        format.html { redirect_to(after_sign_in_path_for(current_user)) }
        format.json { head :no_content }
      end
    else
      flash[:error] = I18n.t('projects.could_not_delete')
      redirect_to(after_sign_in_path_for(current_user))
    end
  end

  def change_project
    change_project_cookie(params[:id])
    redirect_to root_path
    flash[:success] = I18n.t('projects.project_name', parameter: "#{Project.find(params[:id]).name}")
  end



  private
    def change_project_cookie (project)
      cookies.permanent[:project] = {
        value: project,
        domain: :all,
        expires: 1.day
      }
    end

  def project_params
    params.require(:project).permit(:name)
  end

  def set_current_project
    @current_project = current_user.projects.friendly.find(params[:id])
  end

  def validate_owner
    raise_not_found if not @current_project.owned?(current_user.id)
  end

  # make sure the user doesn't delete his/her last project
  def validate_project_count
    if current_user.projects.enabled.size == 1
      flash[:error] = I18n.t('projects.could_not_delete')
      redirect_to root_path
    end
  end
end
