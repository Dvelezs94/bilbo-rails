class BoardCampaignsContoller < ApplicationController
  access provider: :all
  before_action :get_board_campaign
  before_action :validate_provider

  def approve_campaign
    if @campaign.board_campaigns.where(board_id: params[:board_id]).approved!
      flash[:success] = I18n.t('campaign.action.saved')
    else
      flash[:error] = I18n.t('campaign.errors.no_save')
    end
    redirect_to review_campaigns_path
  end

  def deny_campaign
    if @campaign.denied!
      flash[:success] = I18n.t('campaign.action.saved')
    else
      flash[:error] = I18n.t('campaign.errors.no_save')
    end
    redirect_to review_campaigns_path
  end

  private

  def get_board_campaign
    @boad_campaign = BoardsCampaigns.where(board_id: params[:board_id], campaign_id: params[:campaign_id])
  end

  def validate_provider
    raise_not_found if not @board_campaign.board.project.admins.include? current_user.id
  end
end
