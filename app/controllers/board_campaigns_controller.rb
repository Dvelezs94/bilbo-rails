class BoardCampaignsController < ApplicationController
  access provider: :all
  before_action :get_board_campaign
  before_action :validate_provider

  def approve_campaign
    if @board_campaign.approved!
      if @board_campaign.board_errors.nil?
        flash[:success] = I18n.t('campaign.to_active', locale: current_user.locale)
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
    if @board_campaign.denied!
      flash[:success] = I18n.t('campaign.action.saved')
    else
      flash[:error] = I18n.t('campaign.errors.no_save')
    end
  redirect_to provider_index_campaigns_path
 end

  def in_review_campaign
    if @board_campaign.in_review!
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

  def validate_provider
    raise_not_found if not @board_campaign.board.project.admins.include? current_user.id
  end
end
