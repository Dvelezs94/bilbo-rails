class DashboardsController < ApplicationController
  access user: [:index]

  def index
    if current_user.role == :user
      @campaigns = current_user.campaigns.order(updated_at: :desc)
      render "campaigns_index"
    elsif current_user.role == :provider
      render "provider_index"
    end
  end

end
