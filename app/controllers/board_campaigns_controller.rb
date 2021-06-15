class BoardCampaignsController < ApplicationController
  access [:provider, :user] => :all
  before_action :validate_admin_project_board, only: [:multiple_update]
  before_action :get_board_campaign
  before_action :validate_provider_admin

  def approve_campaign
    if @board_campaign.update(status: "approved", make_broadcast: true, user_locale: current_user.locale)
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
    if @board_campaign.update(status: "denied", make_broadcast: true, user_locale: current_user.locale)
      flash[:success] = I18n.t('campaign.action.saved')
    else
      flash[:error] = I18n.t('campaign.errors.no_save')
    end
  redirect_to provider_index_campaigns_path(q:"review")
 end

  def in_review_campaign
    if @board_campaign.update(status: "in_review", make_broadcast: true, user_locale: current_user.locale)
     flash[:success] = I18n.t('campaign.action.to_review', locale: current_user.locale)
    else
     flash[:error] = I18n.t('campaign.errors.no_save', locale: current_user.locale)
    end
   redirect_to provider_index_campaigns_path
  end

  def multiple_update
    if params[:board_campaign_ids].present?
      @boards = params[:board_campaign_ids].split(",")
      @boards.each do |board_campaign_id|
      @board_campaign = BoardsCampaigns.find(board_campaign_id)
        if @board_campaign.update(status: params[:status], make_broadcast: true, user_locale: current_user.locale)
          if @board_campaign.board_errors.nil?
            flash[:success] = I18n.t('campaign.approved', locale: current_user.locale) if params[:status] == "approved"
            flash[:success] = I18n.t('campaign.in_review', locale: current_user.locale) if params[:status] == "in_review"
            flash[:success] = I18n.t('campaign.denied', locale: current_user.locale) if params[:status] == "denied"
          else
            flash[:error] = ActionView::Base.full_sanitizer.sanitize("#{I18n.t('campaign.ads_rotation_error.accepted_but_error', error: @board_campaign.board_errors.first, locale: current_user.locale)}")
          end
        end
      end
      redirect_to request.referer
    end

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

  def validate_admin_project_board
    if params[:board_campaign_ids].present?
      @boards = params[:board_campaign_ids].split(",")
      @board_campaign = BoardsCampaigns.find(@boards.first)
      if !@board_campaign.board.project.admins.include?(current_user.id)
        flash[:error] = I18n.t('campaign.errors.not_enough_permissions')
        redirect_to request.referer
      end
    end
  end
end
