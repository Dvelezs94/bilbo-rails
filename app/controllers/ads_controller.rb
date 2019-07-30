class AdsController < ApplicationController
  access user: :all, provider: {except: [:new]}
  before_action :get_ads, only: [:index]
  before_action :get_ad, only: [:show]
  before_action :verify_identity, only: [:show]

  def index
  end

  def new
  end

  def show
  end

  def edit

  end

  def update

  end

  def create
    @ad = Ad.new(ad_params)
    if @ad.save
      flash[:success] = "Ad saved"
    else
      flash[:error] = "Could not save ad"
    end
    redirect_to ad_path(@ad)
  end

  def destroy

  end

  def destroy_multimedia

  end
  private
  def ad_params
    params.require(:ad).permit(:name, :description, multimedia: []).merge(:user_id => current_user.id)
  end

  def get_ads
    @ads = current_user.ads.with_attached_multimedia
  end

  def get_ad
    @ad = Ad.with_attached_multimedia.find(params[:id])
  end

  def verify_identity
    redirect_to ads_path if @ad.user != current_user
  end
end
