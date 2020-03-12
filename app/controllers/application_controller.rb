class ApplicationController < ActionController::Base
  layout :set_layout
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_project

  # require accout helper
  def require_project!
    redirect_to root_url(subdomain: "app") if request.subdomain != "app"
  end

  # Override devise methods so there are no routes conflict with devise being at /
  def after_sign_in_path_for(resource)
    dashboards_url(subdomain: resource.project_users.first.project.slug)
  end

  def after_sign_out_path_for(resource)
    root_url(subdomain: "app")
  end

  def raise_not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  protected
  # find the company for the multi tenancy
  def set_project
    if request.subdomain.present? && request.subdomain != "app" && user_signed_in? && current_user.role == :user
      @project = Project.includes(:project_users).friendly.find(request.subdomain)
    end
  end

  # add extra registration fields for devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :project_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar, :locale])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:project_name])
  end

  def set_locale
    I18n.locale = params[:locale] ||
      get_locale_from_db ||
      extract_locale_from_accept_language_header ||          # Language header - browser config
      I18n.default_locale               # Set in your config files, english by default
  end

  # Extract language from request header
  def extract_locale_from_accept_language_header
    if request.env['HTTP_ACCEPT_LANGUAGE']
      lg = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.to_sym
      lg.in?([:en, :es]) ? lg : nil
    end
  end

  def get_locale_from_db
   if user_signed_in?
     current_user.locale.to_sym rescue false
   end
  end

  # Set different layout depending on user role
  def set_layout
    if user_signed_in?
      if current_user.role == :user
        'user'
      elsif current_user.role == :provider
        'provider'
      elsif current_user.role == :admin
        'admin'
      end
    # When board is accesed by an anonymous user
    elsif params[:id].present? && request.path == board_path(params[:id])
      'provider'
    # When no user is idenfitied
    else
      'user'
    end
  end
end
