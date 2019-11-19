class AdsController < ApplicationController
  access user: :all, provider: {except: [:new]}
  before_action :get_ad, only: [:show, :destroy, :update]
  before_action :verify_identity, only: [:show, :destroy, :update]

  def index
    get_active_ads
  end

  def show
  end

  def edit

  end

  def update
    respond_to do |format|
      if @ad.update_attributes(ad_params)
        format.html { redirect_to @ad, notice: 'Ad was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "show" }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @ad = Ad.new(ad_params)
    if ! @ad.save
      flash[:error] = "Error"
    end
    redirect_to ad_path(@ad)
  end

  def destroy
    if @ad.update(status: "deleted")
      respond_to do |format|
        format.html { redirect_to ads_path }
        format.json { head :no_content }
      end
    else
      flash[:error] = @ad.errors.full_messages.first
      redirect_to ads_path
    end
  end

  private
  def ad_params
    params.require(:ad).permit(:name, :description).merge(:user_id => current_user.id)
  end

  def get_ads
    @ads = current_user.ads.order(updated_at: :desc).with_attached_multimedia
  end

  def get_active_ads
    @ads = current_user.ads.active.order(updated_at: :desc).with_attached_multimedia
  end

  def get_ad
    @ad = Ad.with_attached_multimedia.friendly.find(params[:id])
  end

  def verify_identity
    redirect_to ads_path if @ad.user != current_user
  end
end
