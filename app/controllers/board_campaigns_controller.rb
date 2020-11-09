class BoardCampaignsController < ApplicationController
  access provider: :all
  before_action :get_board_campaign
  before_action :validate_provider

  def approve_campaign
    if @board_campaign.update(status: "approved", make_broadcast: true)
      # Initialize or compute the remaining_impressions field from BoardsCampaigns (for user campaigns)
      c = @board_campaign.campaign
      if !c.provider_campaign
        b = @board_campaign.board
        max_imp = (c.budget_per_bilbo/b.get_cycle_price(c)).to_i
        impression_count = c.daily_impressions(Time.now.beginning_of_day .. Time.now.end_of_day, b.id)
        today_impressions = impression_count.present?? impression_count.values[0] : 0
        @board_campaign.update(remaining_impressions: max_imp - today_impressions)
      end

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

  def validate_provider
    raise_not_found if not @board_campaign.board.project.admins.include? current_user.id
  end
end
