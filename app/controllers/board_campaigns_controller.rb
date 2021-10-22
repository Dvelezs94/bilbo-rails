class BoardCampaignsController < ApplicationController
  access [:provider, :user] => :all, [:all] => [:show]
  before_action :validate_admin_project_board, only: [:multiple_update]
  before_action :get_board_campaign, except: [:show]
  before_action :get_board_campaign_by_slug, only: [:show]
  before_action :validate_provider_admin, except: [:show]

  def show
    # Method used for displaying a campaign on certain board
    # this is used by other players so they can display the campaign via URL

    # If access token is not valid, then raise error. This ensures only people with the shared secret have access
    if !is_token_valid?
      raise_not_found
    end

    @campaign = @board_campaign.campaign
    @board = @board_campaign.board
    # Set a single content per request
    # if you want a speciif content, you need to set the order in the array of where it is located
    # http://app.bilbo.mx/campaigns/xxxxx/boards/yyyy/show?access_token=supersecret&content=1 - this will use the second content in the array
    all_content = @board_campaign.board.get_content(@board_campaign.campaign)
    if params[:content].present?
      @media = all_content[params[:content].to_i] || all_content.first
    else
      # if no content is chosen then we use the first in the array
      @media = all_content.first
    end
    if @campaign.should_run?(@board.id)
      ProcessGraphqlImpressionsWorker.perform_async(SecureRandom.hex(7), @board.api_token, @board.slug, @campaign.id, 1, Time.zone.now)
    end
  end

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
          else
            flash[:error] = ActionView::Base.full_sanitizer.sanitize("#{I18n.t('campaign.ads_rotation_error.accepted_but_error', error: @board_campaign.board_errors.first, locale: current_user.locale)}")
          end
        end
      end
      redirect_to request.referer
    end

  end


  def get_denied_board_campaigns
    if params[:board_campaign_ids].present?
      @denied_campaigns = params[:board_campaign_ids].split(",")
      respond_to do |format|
        format.js { render "/dashboards/denied_campaign.js.erb", :locals => {:campaigns => @denied_campaigns }}
      end
    end
    if params[:boards_campaigns].present?
      campaigns = []
      @boards = params[:boards_campaigns][:denied_campaigns].split(" ")
      @boards.each do |board_campaign_id|
      @board_campaign = BoardsCampaigns.find(board_campaign_id)
      if @board_campaign.update(status: "denied", make_broadcast: true, user_locale: current_user.locale)
        flash[:success] = I18n.t('campaign.denied', locale: current_user.locale)
      else
        flash[:error] = ActionView::Base.full_sanitizer.sanitize("#{I18n.t('campaign.ads_rotation_error.accepted_but_error', error: @board_campaign.board_errors.first, locale: current_user.locale)}")
      end
      DeniedCampaignsExplanation.where(boards_campaigns_id: board_campaign_id).first_or_create(message: params[:boards_campaigns][:message])
      if !campaigns.include? @board_campaign.campaign
        campaigns.push(@board_campaign)
      end
    end

      notification_campaigns_boards =  campaigns.map{|camp|
        denied_campaigns= DeniedCampaignsExplanation.where(boards_campaigns_id: camp.campaign.board_campaigns)
        {id: camp.campaign, boards: denied_campaigns.map{|denied| denied.boards_campaigns.board if denied.boards_campaigns.status == "denied"}, message: denied_campaigns.map{|denied| denied.message}.uniq }}.uniq
      i = notification_campaigns_boards.length
      i.times do |index|
        create_notification(recipient_id: notification_campaigns_boards[index][:id].project.id,
                            actor_id: notification_campaigns_boards[index][:boards][0].project.id,
                            action: "denied", notifiable: notification_campaigns_boards[index][:id],
                            custom_message: notification_campaigns_boards[index][:boards].pluck(:name).join(", ") + " " + params[:boards_campaigns][:message])
      end
      redirect_to request.referer
    end
  end

  private

  def get_board_campaign
    @board_campaign = BoardsCampaigns.find_by(board_id: params[:board_id], campaign_id: params[:campaign_id])
  end

  def get_board_campaign_by_slug
    campaign_id = Campaign.friendly.find(params[:campaign_id])
    board_id = Board.friendly.find(params[:board_id])
    @board_campaign = BoardsCampaigns.find_by(board_id: board_id, campaign_id: campaign_id)
  end

  def validate_provider_admin
    if not current_project.admins.include? current_user.id
      flash[:error] = I18n.t('campaign.errors.not_enough_permissions')
      redirect_to request.referer
    end
  end

  def is_token_valid?
    if @board_campaign.access_token == params[:access_token]
        return true
    else
        return false
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
