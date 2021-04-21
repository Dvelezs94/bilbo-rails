class AdsController < ApplicationController
  access user: :all, provider: :all
  before_action :get_ad, only: [:show, :destroy, :update]
  #before_action :verify_identity, only: [:show, :destroy, :update]

  def index
    @ad_upcoming = get_active_ads.page(params[:ad_upcoming_page]).per(11)
    respond_to do |format|
        format.js
        format.html
      end
  end

  def show
  end

  def edit

  end

  def update
    respond_to do |format|
      if @ad.update(ad_params)
        format.html { redirect_to @ad, notice: I18n.t('ads.action.update_duration') }
        format.json { head :no_content }
      else
        format.html {
          flash[:error] = @ad.errors.full_messages.to_sentence
          render action: "show"
        }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @ad = Ad.new(ad_params)
    if ! @ad.save
      flash[:error] = "Error"
    end
    # if ad is created from campaign wizard, create param to then redirect once the content is uploaded
    ref = Rails.application.routes.recognize_path(request.referrer)
    if ref[:controller] == "campaigns" && request.referer.include?("gtm_campaign_create")
      redirect_to ad_path(@ad, campaign_ref: ref[:id], gtm_wizard_upload_ad_create: true)
    elsif ref[:controller] == "campaigns" && request.referer.include?("gtm_campaign_edit")
      redirect_to ad_path(@ad, campaign_ref: ref[:id], gtm_wizard_upload_ad_edit: true)
    else
      redirect_to ad_path(@ad)
    end
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

  def wizard_fetch
    if @project.ads.find(params[:ad_id]).present?
      @ads_selected = @project.ads.find(params[:ad_id]).multimedia.attachments
      render  'wizard_fetch', :locals => {:obj => @ads_selected}
    end
  end


  private
  def ad_params
    params.require(:ad).permit(:name, :description, :duration).merge(:project_id => @project.id)
  end

  def get_ads
    @ads = @project.ads.order(updated_at: :desc).with_attached_multimedia
  end

  def get_active_ads
    @ads = @project.ads.active.order(updated_at: :desc).with_attached_multimedia
  end

  def get_ad
    @ad = Ad.with_attached_multimedia.where(project: @project).friendly.find(params[:id])
  end

  def verify_identity
    redirect_to ads_path if @ad.user != current_user
  end
end
