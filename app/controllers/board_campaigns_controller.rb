class BoardCampaignsController < ApplicationController
  access provider: :all
  before_action :get_board_campaign
  #before_action :validate_provider

  def approve_campaign
    if get_board_campaign.update(status:2)
      flash[:success] = I18n.t('campaign.action.saved')
    else
      flash[:error] = I18n.t('campaign.errors.no_save')
    end
    redirect_to provider_index_campaigns_path
  end

  def deny_campaign
    if get_board_campaign.update(status:3)
      flash[:success] = I18n.t('campaign.action.saved')
    else
      flash[:error] = I18n.t('campaign.errors.no_save')
    end
    redirect_to provider_index_campaigns_path
  end

  private

  def get_board_campaign
    @board_campaign = BoardsCampaigns.where(board_id: params[:board_id], campaign_id: params[:campaign_id])
  end

  def validate_provider
    raise_not_found if not @board_campaign.board.project.admins.include? current_user.id
  end
end
