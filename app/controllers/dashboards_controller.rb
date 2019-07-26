class DashboardsController < ApplicationController
  access user: [:index]

  def index
    if current_user.role == :user
      render "index"
    elsif current_user.role == :provider
      render "provider_index"
    end
  end

end
