class DashboardsController < ApplicationController
  access all: [:index], provider: [:provider_statistics]
  before_action :provider_metrics, only: :provider_statistics

  def index
    if current_user && current_user.role == :user
      redirect_to campaigns_path
    elsif current_user && current_user.role == :provider
      redirect_to owned_boards_path
    else
      redirect_to new_user_session_path
    end
  end

  def provider_statistics
  end

  private
  def provider_metrics
    @board_impressions = current_user.impressions_by_boards(4.weeks.ago)
  end

end
