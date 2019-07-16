class ApplicationController < ActionController::Base

  # Override devise methods so there are no routes conflict with devise being at /
  def after_sign_in_path_for(resource_or_scope)
    dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
