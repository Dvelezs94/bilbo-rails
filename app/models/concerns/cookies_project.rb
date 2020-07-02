module CookiesProject
  extend ActiveSupport::Concern
  def change_project
    change_project_cookie(params[:id])
    flash[:success] = I18n.t('projects.project_name', parameter: "#{Project.friendly.find(params[:id]).name}")
    redirect_to root_path
  end

  private

  def change_project_cookie (project)
    cookies.permanent[:project] = {
      value: project,
      domain: :all,
      expires: 1.day
    }
  end
end
