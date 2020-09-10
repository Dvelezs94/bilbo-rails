class Admin::BoardActionsController < ApplicationController
  access admin: :all
  before_action :get_board, only: [:regenerate_ads_rotation, :get_ads_rotation_build]
  before_action :get_provider, only: [:provider_statistics]

  # statistics of a singular board
  def provider_statistics
    ##we need to secure this in case the user has more than 1 project in the future
    @project = @user.projects.first
    @chosen_month = Time.zone.parse(params[:select][:year] + "-" + Date::MONTHNAMES[params[:select][:month].to_i]) rescue Time.zone.now.beginning_of_month
    @start_date = @chosen_month - 1.month + 25.days
    @end_date = @chosen_month + 25.days
    # end date goes first because we have to check the previous month first
    @monthly_earnings = Board.monthly_earnings_by_board(@project, @start_date..@end_date)
    @monthly_impressions = Board.monthly_impressions(@project, @start_date..@end_date)
    @earnings = Board.daily_provider_earnings_by_boards(@project, @start_date..@end_date)
  end

  def regenerate_ads_rotation
    if @board.update_ads_rotation
      flash[:success] = "Ads rotation updated"
    else
      flash[:error] = "Error regenerating ads rotation"
    end
    redirect_to admin_users_path(role: "provider")
  end

  # gets the ads rotation that is used by the provider
  def get_ads_rotation_build
  end


  private

  def get_provider
    @user = User.find(params[:id])
  end

  def get_board
      @board = Board.friendly.find(params[:id])
  end
end
