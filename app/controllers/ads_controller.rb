class AdsController < ApplicationController
  access user: :all, provider: {except: [:new]}
  before_action :get_ads, only: [:index]
  before_action :get_ad, only: [:show, :add_multimedia, :destroy_multimedia]
  before_action :verify_identity, only: [:show, :add_multimedia]
  skip_before_action :verify_authenticity_token, only: [:add_multimedia]


  def index
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

  def add_multimedia
    @ad.multimedia.attach(params[:files])
  end

  def destroy_multimedia
    @ad.multimedia.find_by_id(params[:attachment_id]).purge
    respond_to do |format|
      format.html { redirect_to ad_path(@ad) }
      format.json { head :no_content }
    end
  end

  private
  def ad_params
    params.require(:ad).permit(:name, :description).merge(:user_id => current_user.id)
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
