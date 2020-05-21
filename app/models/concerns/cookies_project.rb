module CookiesProject
  extend ActiveSupport::Concern
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

end
