class AdsController < ApplicationController
  access user: :all, provider: {except: [:new]}
  before_action :get_ads, on: [:index]

  def index
  end

  def new
  end

  def create
    @ad = Ad.new(ad_params)
    if @ad.save
      flash[:success] = "Ad saved"
    else
      flash[:error] = "Could not save ad"
    end
    redirect_to ads_path
  end
  private
  def ad_params
    params.require(:ad).permit(:name, :description, multimedia: []).merge(:user_id => current_user.id)
  end

  def get_ads
    @ads = current_user.ads
  end
end
