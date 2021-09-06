class ChartsController < ApplicationController
  access user: :all, all: [:daily_impressions, :daily_invested, :peak_hours]
  before_action :get_campaign, only: [:daily_impressions, :daily_invested, :peak_hours, :daily_qr_code_scans]
  before_action :get_board, only: [:daily_earnings, :campaign_of_day, :impressions_count, :top_campaigns]
  # Campaign Charts
  def monthly_statistics
    render json: @campaign.monthly_statistics
  end

  def daily_impressions
    #impressions = hash_initialize(params[:start_date], params[:end_date]).merge(@campaign.daily_impressions(start_date: params[:start_date], end_date: params[:end_date]))
    #impressions = Hash[impressions.map{|key,value| [key.capitalize, value]}]  
    render json: @campaign.boards.map{|board| {name: board.name, data: board.impressions.where(campaign_id: @campaign.id, created_at: params[:start_date]..params[:end_date]).group_by_day(:created_at, format: "%b %d").count}}
  end

  def daily_impressions_month
    render json: @campaign.daily_impressions_month
  end

  def daily_qr_code_scans
    scans = hash_initialize(params[:start_date], params[:end_date]).merge(@campaign.qr_shortener.daily_hits(params[:start_date]..params[:end_date]))
    scans = Hash[scans.map{|key, value| [key.capitalize, value]}]
    render json: scans
  end

  def daily_invested
    #render json: @campaign.daily_invested(start_date: params[:start_date], end_date: params[:end_date])
    render json: @campaign.boards.map{|board| {name: board.name, data: board.impressions.where(campaign_id: @campaign, created_at: params[:start_date]..params[:end_date]).group_by_day(:created_at, format: "%a").sum(:total_price)}}
  end

  def peak_hours
    #render json: @campaign.peak_hours(start_date: params[:start_date], end_date: params[:end_date])
    render json: @campaign.boards.map{|board| {name: board.name, data: board.impressions.where(campaign_id: @campaign, created_at: params[:start_date]..params[:end_date]).group_by_hour_of_day(:created_at, format: "%l %P").count}}
  end

  def daily_earnings
    render json: @board.provider_daily_earnings
  end

  def campaign_of_day
    render json: @board.campaign_of_day
  end

  def impressions_count
    render json: @board.impressions_single
  end

  def top_campaigns
    render json: Board.provider_top_campaigns(@board, 3.months.ago..Time.now, 2).first(4)
  end
  # End Campaign Charts

  private

  def get_campaign
    @campaign = Campaign.find_by_slug(params[:id])
  end

  def get_board
    @board = Board.find_by_slug(params[:id])
  end

  def hash_initialize(date_start, date_end)
    date_start = date_start.to_date
    date_end = date_end.to_date
    time_range = {}
    while date_start <= date_end do
      time_range[(I18n.l date_start, format: "%b %d")] = 0
      date_start += 1.day
    end
    return time_range
  end

end
