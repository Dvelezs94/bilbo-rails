class ProjectsController < ApplicationController
  include CookiesProject
  access user: :all
  before_action :set_selected_project, only: :destroy
  before_action :verify_identity, only: [:update]
  before_action :validate_owner, only: :destroy
  before_action :validate_project_count, only: :destroy

  def index
    @projects = current_user.projects.includes(:project_users, :campaigns).enabled
  end

  def create
    @new_project = Project.new(project_params)
    @new_project.project_users.new(user: current_user, role: "owner")

    if @new_project.save
      flash[:success] = I18n.t('projects.successfully_created')
      change_project_cookie(@new_project.slug)
    else
      flash[:error] = @new_project.errors.full_messages.to_sentence
    end
    redirect_to root_url()
  end

  def destroy
    # attempt to stop all campaigns before deleting (disabling) the project
    if @selected_project.campaigns.update(state: false)
      @selected_project.update(status: "disabled")
      respond_to do |format|
        format.html { flash[:success] = I18n.t('projects.deleted_project')
          redirect_to(after_sign_in_path_for(current_user)) }
        format.json { head :no_content }
      end
    else
      flash[:error] = I18n.t('projects.could_not_delete')
      redirect_to(after_sign_in_path_for(current_user))
    end
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end

  def set_selected_project
    @selected_project = current_user.projects.friendly.find(params[:id])
  end

  def validate_owner
    raise_not_found if not @selected_project.owned?(current_user.id)
  end

  # make sure the user doesn't delete his/her last project
  def validate_project_count
    if current_user.owned_projects.count == 1
      flash[:error] = I18n.t('projects.could_not_delete')
      redirect_to projects_path
    end
  end
end
