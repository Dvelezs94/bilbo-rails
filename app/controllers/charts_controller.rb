class ChartsController < ApplicationController
  access user: :all
  before_action :get_campaign, only: [:daily_impressions, :daily_invested, :peak_hours]

  # Campaign Charts
  def daily_impressions
    render json: @campaign.daily_impressions
  end

  def daily_invested
    render json: @campaign.daily_invested
  end

  def peak_hours
    render json: @campaign.peak_hours
  end
  # End Campaign Charts

  private

  def get_campaign
    @campaign = Campaign.find_by_slug(params[:id])
  end
end
