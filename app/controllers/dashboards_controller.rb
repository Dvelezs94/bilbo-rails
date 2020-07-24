class DashboardsController < ApplicationController
  access all: [:index], provider: [:provider_statistics, :monthly_statistics]
  before_action :provider_metrics, only: :provider_statistics

  def index
    if user_signed_in?
      if current_user.role == :user
        redirect_to campaigns_path
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
    if params.has_key?(:select)
      @start_date = (params[:select][:year]+"-" +params[:select][:month]+"-"+Date.today.day.to_s).to_datetime.beginning_of_month
      @end_date = @start_date.end_of_month
      @jobs = Impression.where("created_at BETWEEN ? AND ?",@start_date, @end_date)
      @daily_impressions = @project.daily_provider_board_impressions(@start_date..@end_date).group_by_day(:created_at).count
      @graph_earnings = Board.daily_provider_earnings_graph(@project, @start_date..@end_date)
      @earnings = Board.daily_provider_earnings_by_boards(@project, @start_date..@end_date)
      @monthly_earnings = Board.monthly_earnings_by_board(@project, @start_date..@end_date)
      @monthly_impressions = Board.monthly_impressions(@project, @start_date..@end_date)
      @tops = Board.top_campaigns(@project, @start_date..@end_date).first(3)
      @substraction_tops= Impression.joins(:campaign,:board).where(boards: {project: @project}, created_at: @start_date..@end_date).sum(:total_price)
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
        @others_earnings=@substraction_tops - @tops.first[2]-@tops.second[2]-@tops.third[2]
      end
    else
      @daily_impressions = @project.daily_provider_board_impressions().group_by_day(:created_at).count
      @graph_earnings = Board.daily_provider_earnings_graph(@project)
      @earnings = Board.daily_provider_earnings_by_boards(@project)
      @monthly_earnings = Board.monthly_earnings_by_board(@project)
      @monthly_impressions = Board.monthly_impressions(@project)
      @tops = Board.top_campaigns(@project).first(3)
      @substraction_tops= Impression.joins(:campaign,:board).where(boards: {project: @project}, created_at: 30.days.ago..Time.now).sum(:total_price)
      @tops_four = Board.top_campaigns(@project).first(4)
      @percentage = Board.top_campaigns(@project).each.map{|p| p[1]}.sum
      @substraction = Board.top_campaigns(@project).each.map{|p| p[1]}.sum-@tops.each.map{|p| p[1]}.sum
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
        @others_earnings=@substraction_tops - @tops.first[2]-@tops.second[2]-@tops.third[2]
      end
    end
  end

  private
  def provider_metrics
    @board_impressions = @project.impressions_by_boards(4.weeks.ago)
  end

end
