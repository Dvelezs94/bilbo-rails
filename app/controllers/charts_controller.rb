class ChartsController < ApplicationController
  access user: :all
  before_action :get_campaign, only: [:daily_impressions, :daily_invested, :peak_hours]
  before_action :get_board, only: [:daily_earnings, :campaign_of_day, :impressions_count, :top_campaigns]
  # Campaign Charts
  def monthly_statistics
    render json: @campaign.monthly_statistics
  end 

  def daily_impressions
    render json: @campaign.daily_impressions()
  end

  def daily_impressions_month
    render json: @campaign.daily_impressions_month
  end

  def daily_invested
    render json: @campaign.daily_invested
  end

  def peak_hours
    render json: @campaign.peak_hours
  end

  def daily_earnings
    render json: @board.daily_earnings
  end

  def campaign_of_day
    render json: @board.campaign_of_day
  end

  def impressions_count
    render json: @board.impressions_single
  end

  def top_campaigns
    render json: Board.top_campaigns(@board, 3.months.ago..Time.now, 2).first(4)
  end
  # End Campaign Charts

  private

  def get_campaign
    @campaign = Campaign.find_by_slug(params[:id])
  end

  def get_board
    @board = Board.find_by_slug(params[:id])
  end
  
end
