class ProjectsController < ApplicationController
  access user: :all
  before_action :set_current_project, only: :destroy
  before_action :verify_identity, only: [:update]
  before_action :validate_owner, only: :destroy
  before_action :validate_project_count, only: :destroy

  def index
    @projects = current_user.projects.includes(:project_users, :campaigns, :ads)
  end

  def create
    @new_project = Project.new(project_params)
    @new_project.project_users.new(user: current_user, role: "owner")

    if @new_project.save
      flash[:success] = I18n.t('project.successfully_created')
    else
      flash[:error] = I18n.t('project.error')
    end
    redirect_to root_url(subdomain: @new_project.slug)
  end

  def destroy
    if @current_project.update(status: "disabled")
      respond_to do |format|
        format.html { redirect_to root_url(subdomain: current_user.projects.first.slug) }
        format.json { head :no_content }
      end
    else
      flash[:error] = "Error"
      redirect_to projects_path
    end
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end

  def set_current_project
    @current_project = current_user.projects.friendly.find(params[:id])
  end

  def validate_owner
    raise_not_found if not @current_project.owners.include? current_user.id
  end

  # make sure the user doesn't delete his/her last project
  def validate_project_count
    if current_user.projects_owned.size == 1
      flash[:error] = "Error"
      redirect_to root_path
    end
  end
end
