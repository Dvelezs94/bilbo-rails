class CampaignsController < ApplicationController
  include UserActivityHelper
  access user: {except: [:review, :approve_campaign, :deny_campaign, :provider_index]}, provider: :all, all: [:analytics, :shortened_analytics]
  before_action :get_campaigns, only: [:index]
  before_action :get_campaign, only: [:edit, :destroy, :update, :toggle_state, :get_used_boards]
  before_action :verify_identity, only: [:edit, :destroy, :update, :toggle_state, :get_used_boards]
  before_action :campaign_not_active, only: [:edit]

  def index
    @created_ads = @project.ads.present?
    @created_campaigns = @project.campaigns.present?
    @purchased_credits = current_user.payments.present?
    @verified_profile = current_user.verified
    @show_hint = !(@created_ads && @created_campaigns && @purchased_credits && @verified_profile)
  end

  def provider_index
    if params[:q] == "review"
      Campaign.active.where.not(ad_id: nil).joins(:boards).merge(@project.boards).uniq.pluck(:id).each do |c|
        #Search for ads that haven't been processed
         if Ad.find(Campaign.find(c).ad_id).processed?
            @camp = Array(@camp).push(c)
         end
       end
      @board_campaigns = BoardsCampaigns.where(board_id: @project.boards.enabled.pluck(:id), campaign_id: @camp).in_review
    elsif params[:bilbo].present?
      @board_campaigns = BoardsCampaigns.where(board_id: @project.boards.enabled.friendly.find(params[:bilbo]), campaign_id: Campaign.active.joins(:boards).merge(@project.boards).uniq.pluck(:id)).approved rescue nil
    else
      @board_campaigns = BoardsCampaigns.where(board_id: @project.boards.enabled.pluck(:id), campaign_id: Campaign.active.joins(:boards).merge(@project.boards).uniq.pluck(:id)).approved
    end
  end

  def getAds
    campaign = Campaign.find(params[:id])
    if campaign.should_run?(params[:board_id].to_i)
      @append_msg = ApplicationController.renderer.render(partial: "campaigns/board_campaign", collection: campaign.ad.multimedia, locals: {campaign: campaign},as: :media)
    else
      @append_msg = ""
    end
  end

  def get_used_boards
    @board_campaigns = @campaign.board_campaigns.includes(:board)
  end

  def analytics
    @campaign = Campaign.includes(:boards, :impressions).friendly.find(params[:id])
    @history_campaign = UserActivity.where( activeness: @campaign).order(created_at: :desc)
    @campaign_impressions = {}
    @impressions = Impression.where(campaign: @campaign, created_at: 1.month.ago..Time.zone.now)
    @total_invested = @impressions.sum(:total_price).round(3)
    @total_impressions = @impressions.count
    @impressions.group_by_day(:created_at).count.each do |key, value|
      @campaign_impressions[key] = {impressions_count: value, total_invested: @impressions.group_by_day(:created_at).sum(:total_price)[key].round(3)}
    end
    return @campaign_impressions
  end

  def edit
    @ads = @project.ads.active.order(updated_at: :desc).with_attached_multimedia.select{ |ad| ad.multimedia.any? }
    @campaign_boards =  @campaign.boards.enabled.collect { |board| ["#{board.address} - #{board.face}", board.id, { 'data-max-impressions': JSON.parse(board.ads_rotation).size, 'data-price': board.cycle_price/board.duration, 'new-height': board.size_change[0].round(0), 'new-width': board.size_change[1].round(0), 'data-cycle-duration': board.duration } ] }
    @campaign.starts_at = @campaign.starts_at.to_date rescue ""
    @campaign.ends_at = @campaign.ends_at.to_date rescue ""
    if current_user.is_provider?
      @boards = @project.boards
    else
      @boards = Board.enabled
    end
  end

  def toggle_state
    current_user.with_lock do
      @campaign.with_lock do
        @success = @campaign.update(state: !@campaign.state)
      end
      if @success
        if @campaign.state
          track_activity( action: "campaign.campaign_actived", activeness: @campaign)
        else
          track_activity( action: "campaign.campaign_deactivated", activeness: @campaign)
        end
      end
    end
  end


  def update
    current_user.with_lock do
      respond_to do |format|
        if @campaign.update(campaign_params.merge(state: is_state, owner_updated_campaign: true))
          track_activity( action: "campaign.campaign_updated", activeness: @campaign)
          # Create a notification per project
          @campaign.boards.includes(:project).map(&:project).uniq.each do |provider|
            create_notification(recipient_id: provider.id, actor_id: @campaign.project.id,
                                action: "created", notifiable: @campaign, sms: current_user.is_provider? ? false : true)
          if @campaign.starts_at.present? && @campaign.ends_at.present?
            @campaign.boards.each do |b|
              difference_in_seconds = (@campaign.to_utc(@campaign.starts_at, b.utc_offset) - Time.now.utc).to_i
              difference_in_seconds_end = (@campaign.to_utc(@campaign.ends_at, b.utc_offset) - Time.now.utc).to_i
              ScheduleCampaignWorker.perform_at(difference_in_seconds.seconds.from_now, @campaign.id, b.id) if difference_in_seconds > 0
              RemoveScheduleCampaignWorker.perform_at((difference_in_seconds_end.seconds+86401.seconds).from_now, @campaign.id, b.id) if difference_in_seconds_end > 0
            end
          end
        end
          format.js {
            flash[:success] = I18n.t('campaign.action.updated')
            redirect_to campaigns_path
           }
          format.json { head :no_content }
        else
          format.js {
            #nothing, just view
             }
          format.json { render json: @campaign.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def create
    @campaign = Campaign.new(create_params)
      if @campaign.save
        track_activity( action: 'campaign.campaign_created', activeness: @campaign)
        flash[:success] = I18n.t('campaign.action.saved')
      else
        flash[:error] = I18n.t('campaign.errors.no_save')
      end
      redirect_to edit_campaign_path(@campaign)
  end

  def destroy
    if !@campaign.state?
      # Skip validations because the campaign is already disabled
      @campaign.update_attribute(:status, "inactive")
      respond_to do |format|
        format.html {
          flash[:success] = I18n.t('campaign.action.deleted')
           redirect_to campaigns_path
         }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = I18n.t('campaign.errors.cant_update_when_active')
          redirect_to campaigns_path
         }
        format.json { head :no_content }
      end
    end
  end

  def shortened_analytics
    if params[:id].present?
      @campaign = Campaign.find_by_analytics_token(params[:id])
      redirect_to analytics_campaign_path(@campaign.slug)
    end
  end

  private
  def campaign_params
    @campaign_params = params.require(:campaign).permit(:name, :description, :boards, :ad_id, :starts_at, :ends_at, :budget, :hour_start, :hour_finish, :imp, :minutes, impression_hours_attributes: [:id, :day, :imp, :start, :end, :_destroy] ).merge(:project_id => @project.id)
    if @campaign_params[:boards].present?
      @campaign_params[:boards] = Board.where(id: @campaign_params[:boards].split(",").reject(&:empty?))
    end

    @campaign_params[:starts_at] = nil if @campaign_params[:starts_at].nil?
    @campaign_params[:ends_at] = nil if @campaign_params[:ends_at].nil?
    @campaign_params[:hour_start] = @campaign_params[:hour_start]
    @campaign_params[:hour_finish] = @campaign_params[:hour_finish]

    if @campaign_params[:budget].present?
      @campaign_params[:budget] = @campaign_params[:budget].tr(",","").to_f

    #else
     # @campaign_params[:budget] = nil
    end
    @campaign_params
  end

  def create_params
    @campaign_params = params.require(:campaign).permit(:name, :description, :provider_campaign, :clasification).merge(:project_id => @project.id)
    @campaign_params[:provider_campaign] = @project.owner.is_provider?
    @campaign_params
  end

  def get_campaigns
    @campaigns = @project.campaigns.includes(:boards, :impressions).active
  end

  def get_campaign
    @campaign = Campaign.includes(:boards, :impressions).where(project: @project).friendly.find(params[:id])
  end

  def verify_identity
    redirect_to campaigns_path if not @campaign.project.users.pluck(:id).include? current_user.id
  end

  def campaign_not_active
    if @campaign.state
      flash[:error] = I18n.t('campaign.errors.cant_update_when_active')
      redirect_back fallback_location: root_path
    end
  end

  # sets the campaign state automatically
  def is_state
    if current_user.is_user?
      # if owner is verified, then enable campaign automatically
      if @campaign.owner.verified
        true
      else
        false
      end
    # always enable campaigns automatically by providers
    elsif current_user.is_provider?
      return true
    else
      return false
    end
  end
end
