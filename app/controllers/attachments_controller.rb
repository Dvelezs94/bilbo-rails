class AttachmentsController < ApplicationController
  access user: :all, provider: {except: [:new]}
  before_action :get_ad, only: [:create, :destroy]
  before_action :verify_identity, only: [:create, :destroy]
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    if @ad.multimedia.attach(params[:files])
      flash[:success] = "Attachment saved"
    else
      flash[:error] = "Could not save atttachment"
    end
    redirect_to ad_path(@ad)
  end

  def destroy
    @ad.multimedia.find_by_id(params[:id]).purge
    respond_to do |format|
      format.html { redirect_to ad_path(@ad) }
      format.json { head :no_content }
    end
  end

  private
  def ad_params
    params.require(:ad).permit(:name, :description).merge(:user_id => current_user.id)
  end

  def get_ad
    @ad = Ad.with_attached_multimedia.find(params[:ad_id])
  end

  def verify_identity
    redirect_to ads_path if @ad.user != current_user
  end
end
