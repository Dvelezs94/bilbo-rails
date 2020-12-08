class Admin::ProjectsController < ApplicationController
  access admin: :all
  before_action :get_project_by_slug, only: :update_permissions

  def index
    @projects = Project.all
  end

  def update_permissions
    available = []
    if params["budget"].present?
      available.append("budget")
    end
    if params["per_minute"].present?
      available.append("per_minute")
    end
    if params["per_hour"].present?
      available.append("per_hour")
    end

    if available.to_s != @project.available_campaign_types
      if @project.update(available_campaign_types: available.to_s)
        flash[:success] = I18n.t('projects.permissions_changed')
      end
    else
      flash[:success] = I18n.t('projects.nothing_changed')
    end

    redirect_to admin_projects_path
  end

  def get_project_by_slug
    @project = Project.find_by(slug: params[:id])
  end

end
