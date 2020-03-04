class DashboardsController < ApplicationController
  access all: [:index], provider: [:provider_statistics]
  before_action :provider_metrics, only: :provider_statistics

  def index
    if user_signed_in?
      if current_user.role == :user
        redirect_to campaigns_path
      elsif current_user.role == :provider
        redirect_to provider_statistics_dashboards_path
      elsif current_user.role == :admin
        redirect_to admin_index_path
      end
    else
      redirect_to new_user_session_path
    end
  end

  def provider_statistics
    @daily_impressions = current_user.daily_provider_board_impressions().group_by_day(:created_at).count
    @earnings = Board.daily_provider_earnings_by_boards(current_user)
    @monthly_earnings_comparison = Board.monthly_earnings_comparison(current_user)
    @tops = Board.top_monthly_campaigns(current_user).first(4)
  end

  private
  def provider_metrics
    @board_impressions = current_user.impressions_by_boards(4.weeks.ago)
  end

end
