class AttachmentsController < ApplicationController
  access user: :all, provider: {except: [:new]}
  before_action :get_ad, only: [:create, :destroy]
  before_action :verify_identity, only: [:create, :destroy]
  skip_before_action :verify_authenticity_token, only: [:create]
 
  def create
    if @ad.campaigns.all_off && @ad.multimedia.attach(params[:files])
      flash[:success] = "Attachment saved"
    else
      flash[:error] = I18n.t('ads.errors.wont_be_able_to_update')
    end
  end

  def destroy
    respond_to do |format|
      format.html {
        if @ad.campaigns.all_off && @ad.multimedia.find_by_id(params[:id]).purge
          flash[:success] = I18n.t('ads.action.media_removed')
        else
         flash[:error] = I18n.t('ads.errors.wont_be_able_to_update')
        end
       }
      format.json { head :no_content }
    end
    redirect_to ad_path(@ad)
  end

  private

  def get_ad
    @ad = Ad.with_attached_multimedia.friendly.find(params[:ad_id])
    #This is for assign multimedia updates to the ad 
    @ad.multimedia_update = true
    @ad
  end

  def verify_identity
    redirect_to ads_path if @ad.user != current_user
  end
end
