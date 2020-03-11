class ProjectsController < ApplicationController
  access user: :all
  before_action :set_project, only: [:index]
  before_action :verify_identity, only: [:update, :edit, :show]

  def index
    @projects = current_user.projects
  end

  def new
    @project = Project.new
  end

  def show

  end

  def create
    @project = Project.new(project_params)
    @project.project_users.new(user: current_user, role: "owner")

    if @project.save
      flash[:success] = I18n.t('project.successfuly_created')
    else
      flash[:error] = I18n.t('project.error')
    end
    redirect_to root_url(subdomain: @project.slug)
  end

  private

  def campaign_params
    params.require(:project).permit(:name)
  end

  def set_project
    @project = current_user.projects.find(params[:id])
  end

  def verify_identity
    redirect_to root_path if @project.users.pluck(:id).includes(current_user.id)
  end
end
