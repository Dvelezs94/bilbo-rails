class ProjectsController < ApplicationController
  access user: :all
  before_action :set_project, only: [:index]
  before_action :verify_identity, only: [:update, :edit, :show]

  def index
    @projects = current_user.projects
  end

  def new
    @new_project = Project.new
  end

  def show

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

  private

  def campaign_params
    params.require(:project).permit(:name)
  end

  def set_project
    @new_project = current_user.projects.find(params[:id])
  end
end
