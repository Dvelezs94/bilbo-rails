class BoardCampaignsController < ApplicationController
  access [:provider, :user] => :all
  before_action :get_board_campaign
  before_action :validate_provider_admin
  before_action :content_params

  def approve_campaign
    if @board_campaign.update(status: "approved", make_broadcast: true)
      if @board_campaign.board_errors.nil?
        flash[:success] = I18n.t('campaign.accepted', locale: current_user.locale)
      else
        flash[:error] = I18n.t('campaign.ads_rotation_error.accepted_but_error',error: @board_campaign.board_errors.first, locale: current_user.locale)
      end
      #flash[:success] = I18n.t('campaign.action.saved')
    else
      #flash[:error] = I18n.t('campaign.errors.no_save')
      flash[:error] = I18n.t('campaign.errors.not_accepted')
    end
  redirect_to provider_index_campaigns_path(q:"review")
 end

  def deny_campaign
    if @board_campaign.update(status: "denied", make_broadcast: true)
      flash[:success] = I18n.t('campaign.action.saved')
    else
      flash[:error] = I18n.t('campaign.errors.no_save')
    end
  redirect_to provider_index_campaigns_path(q:"review")
 end

  def in_review_campaign
    if @board_campaign.update(status: "in_review", make_broadcast: true)
     flash[:success] = I18n.t('campaign.action.to_review', locale: current_user.locale)
    else
     flash[:error] = I18n.t('campaign.errors.no_save', locale: current_user.locale)
    end
   redirect_to provider_index_campaigns_path
  end

  private

  def get_board_campaign
    @board_campaign = BoardsCampaigns.find_by(board_id: params[:board_id], campaign_id: params[:campaign_id])
  end

  def validate_provider_admin
    if not @project.admins.include? current_user.id
      flash[:error] = I18n.t('campaign.errors.not_enough_permissions')
      redirect_to request.referer
    end
  end

  def content_params
    #@content_params = params.require(:boards_campaigns).permit(content_board_campaign_attributes:[:content_id])
    p "x" *800
    puts params.inspect
  end
end
