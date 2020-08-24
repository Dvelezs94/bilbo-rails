class Admin::BoardActionsController < ApplicationController
  access admin: :all
  # before_action :get_all_boards, only: :show
  before_action :get_provider, only: [:provider_statistics]

  # statistics of a singular board
  def provider_statistics
    ##we need to secure this in case the user has more than 1 project in the future
    @project = @user.projects.first
    @chosen_month = (params[:select][:year] + "-" + Date::MONTHNAMES[params[:select][:month].to_i]).to_datetime
    @start_date = @chosen_month - 1.month + 25.days
    @end_date = @chosen_month + 25.days
    # end date goes first because we have to check the previous month first
    @monthly_earnings = Board.monthly_earnings_by_board(@project, @start_date..@end_date)
    @monthly_impressions = Board.monthly_impressions(@project, @start_date..@end_date)
    @earnings = Board.daily_provider_earnings_by_boards(@project, @start_date..@end_date)
    puts "x" * 500
    puts @start_date..@end_date
  end


  private

  def get_provider
    @user = User.find(params[:id])
  end

  def get_board
      @board = Board.friendly.find(params[:id])
  end
end
