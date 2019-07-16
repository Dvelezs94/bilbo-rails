class ApplicationController < ActionController::Base
  before_action :set_locale
  # Override devise methods so there are no routes conflict with devise being at /
  def after_sign_in_path_for(resource_or_scope)
    dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  protected

  def set_locale
    # Remove inappropriate/unnecessary ones
    I18n.locale = params[:locale] ||
      extract_locale_from_accept_language_header ||          # Language header - browser config
      I18n.default_locale               # Set in your config files, english by super-default
  end

  # Extract language from request header
  def extract_locale_from_accept_language_header
    if request.env['HTTP_ACCEPT_LANGUAGE']
      lg = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.to_sym
      lg.in?([:en, :es]) ? lg : nil
    end
  end
end
