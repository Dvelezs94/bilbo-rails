class DashboardsController < ApplicationController
  include DatesHelper
  access all: [:index], provider: [:provider_statistics, :monthly_statistics]
  before_action :provider_metrics, only: :provider_statistics

  def index
    if user_signed_in?
      if current_user.role == :user
        if current_user.sign_in_count == 0
          redirect_to campaigns_path(account:"set")
        else
          redirect_to campaigns_path
        end
      elsif current_user.role == :provider
        redirect_to provider_statistics_dashboards_path
      elsif current_user.role == :admin
        redirect_to admin_main_index_path
      end
    else
      redirect_to new_user_session_path
    end
  end

  def provider_statistics
    @chosen_month = Time.zone.parse(Date::MONTHNAMES[params[:select][:month].to_i] + " " + params[:select][:year]) rescue Time.zone.now.beginning_of_month
    get_month_cycle(date: @chosen_month)
    @jobs = Impression.where("created_at BETWEEN ? AND ?",@start_date, @end_date)
    @daily_impressions = @project.daily_provider_board_impressions(@start_date..@end_date).group_by_day(:created_at).count
    @graph_earnings = Board.daily_provider_earnings_graph(@project, @start_date..@end_date)
    @earnings = Board.daily_provider_earnings_by_boards(@project, @start_date..@end_date)
    @monthly_earnings = Board.monthly_earnings_by_board(@project, @start_date..@end_date)
    @monthly_impressions = Board.monthly_impressions(@project, @start_date..@end_date)
    @tops = Board.top_campaigns(@project, @start_date..@end_date).first(3)
    @substraction_tops = Impression.joins(:campaign,:board).where(boards: {project: @project}, created_at: @start_date..@end_date).sum(:total_price)
    @tops_four = Board.top_campaigns(@project, @start_date..@end_date).first(4)
    @percentage = Board.top_campaigns(@project, @start_date..@end_date).each.map{|p| p[1]}.sum
    @substraction = Board.top_campaigns(@project, @start_date..@end_date).each.map{|p| p[1]}.sum-@tops.each.map{|p| p[1]}.sum
    if @tops.length >= 1
      @percentage_top_1 = '%.2f' %(@tops[0][1].to_f * 100 / @percentage)
    end
    if @tops.length >= 2
      @percentage_top_2 = '%.2f' %(@tops[1][1].to_f * 100 / @percentage)
    end
    if @tops.length >= 3
      @percentage_top_3 = '%.2f' %(@tops[2][1].to_f * 100 / @percentage)
    end
    if @tops_four.length > 3
      @others = @tops.push([I18n.t('dashboards.others'), @substraction])
      @percentage_top_4 = '%.2f' %(100.to_f - @percentage_top_1.to_f - @percentage_top_2.to_f - @percentage_top_3.to_f)
      @others_earnings = @substraction_tops - @tops.first[2] - @tops.second[2] - @tops.third[2]
    end
  end

  private
  def provider_metrics
    @board_impressions = @project.impressions_by_boards(start: 1.month.ago)
  end
end
