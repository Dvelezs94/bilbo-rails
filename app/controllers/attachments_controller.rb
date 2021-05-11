class AttachmentsController < ApplicationController
  access user: :all, provider: :all
  before_action :get_ad, only: [:create, :destroy, :update]

  def create
    if @ad.campaigns.all_off
      @ad.multimedia.attach(params[:files])
      # VideoConverterWorker.perform_async(@ad.id)
      ImageResizeWorker.perform_async(@ad.id)
      flash[:success] = I18n.t('ads.attachment_saved')
    else
      flash[:error] = I18n.t('ads.errors.wont_be_able_to_update')
    end
  end

  def destroy
    respond_to do |format|
      format.html {
        if @ad.campaigns.all_off
            @ad.multimedia.find_by_id(params[:id]).purge
          flash[:success] = I18n.t('ads.action.media_removed')
        else
         flash[:error] = I18n.t('ads.errors.wont_be_able_to_update')
        end
       }
      format.json { head :no_content }
    end
    redirect_to ad_path(@ad)
  end

  def update
    if @ad.present?
      if @ad.multimedia.find_by_id(params[:id]).update(transition:params[:effect])
        @success_message = I18n.t("ads.transitions.update.success")
      else
        @error_message = I18n.t("ads.transitions.update.error")
      end
    end
  end

  private

  def get_ad
    @ad = Ad.with_attached_multimedia.where(project: @project).friendly.find(params[:ad_id])
    #This is for assign multimedia updates to the ad
    @ad.multimedia_update = true
    @ad
  end

end
