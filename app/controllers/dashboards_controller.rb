class DashboardsController < ApplicationController
  access user: [:index]

  def index
    if current_user.role == :user
      @campaigns = current_user.campaigns.order(updated_at: :desc)
      render "campaigns_index"
    elsif current_user.role == :provider
      provider_metrics
      render "provider_index"
    end
  end

  private
  def provider_metrics
    @board_impressions = current_user.boards_impressions(4.weeks.ago)
  end

end
