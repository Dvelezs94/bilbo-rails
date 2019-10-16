class DashboardsController < ApplicationController
  access user: [:index], provider: [:provider_statistics]
  before_action :provider_metrics, only: :provider_statistics

  def index
    if current_user.role == :user
      @campaigns = current_user.campaigns.order(updated_at: :desc)
      render "campaigns_index"
    elsif current_user.role == :provider
      redirect_to owned_boards_path
    end
  end

  def provider_statistics
  end

  private
  def provider_metrics
    @board_impressions = current_user.impressions_by_boards(4.weeks.ago)
  end

end
