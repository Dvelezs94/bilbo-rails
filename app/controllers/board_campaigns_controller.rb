class BoardCampaignsController < ApplicationController
  access provider: :all
  before_action :get_board_campaign
  before_action :validate_provider

  def approve_campaign
    if @board_campaign.approved!
      @board = @board_campaign.board
      @campaign = @board_campaign.campaign
      success, err = @board.update_ad_rotation(@campaign)
      if success
        flash[:success] = "La campaña está corriendo en el Bilbo"
      else
        @campaign.update(state: false)
        flash[:error] = "La campaña se ha aceptado pero "+ err.first
      end
      #flash[:success] = I18n.t('campaign.action.saved')
    else
      #flash[:error] = I18n.t('campaign.errors.no_save')
      flash[:error] = "La campaña no ha podido aceptarse"
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
     flash[:success] = I18n.t('campaign.action.saved')
    else
     flash[:error] = I18n.t('campaign.errors.no_save')
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
