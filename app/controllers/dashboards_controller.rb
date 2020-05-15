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
        redirect_to admin_main_index_path
      end
    else
      redirect_to new_user_session_path
    end
  end

  def provider_statistics
    @daily_impressions = @project.daily_provider_board_impressions().group_by_day(:created_at).count
    @earnings = Board.daily_provider_earnings_by_boards(@project)
    @tops = Board.top_campaigns(@project).first(3)
    @percentage = Board.top_campaigns(@project).each.map{|p| p[1]}.sum
    @resta = Board.top_campaigns(@project).each.map{|p| p[1]}.sum-Board.top_campaigns(@project).first(3).each.map{|p| p[1]}.sum
    @others = @tops.push([I18n.t('dashboards.others'), @resta])
    if @tops.length >= 1
      @percentage_top_1 = '%.2f' %(@tops[0][1].to_f * 100 / @percentage)
    end
    if @tops.length >= 2
      @percentage_top_2 = '%.2f' %(@tops[1][1].to_f * 100 / @percentage)
    end
    if @tops.length >= 3
      @percentage_top_3 = '%.2f' %(@tops[2][1].to_f * 100 / @percentage)
    end
    if @tops.length == 4
      @percentage_top_4 = '%.2f' %(100.to_f - @percentage_top_1.to_f - @percentage_top_2.to_f - @percentage_top_3.to_f)
    end
  end

  private
  def provider_metrics
    @board_impressions = @project.impressions_by_boards(4.weeks.ago)
  end

end
