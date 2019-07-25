class DashboardsController < ApplicationController
  access user: [:show]

  def show
    if current_user.role == :user
      render "show"
    elsif current_user.role == :provider
      render "provider_home"
    end

  end
end
