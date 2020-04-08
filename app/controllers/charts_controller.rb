class ChartsController < ApplicationController
  access user: :all

  def daily_impressions
    get_campaign
    render json: @campaign.daily_impressions
  end

  private

  def get_campaign
    @campaign = Campaign.find_by_slug(params[:id])
  end
end
