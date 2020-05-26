class CampaignsController < ApplicationController
  access user: {except: [:review, :approve_campaign, :deny_campaign, :provider_index]}, provider: :all
  before_action :get_campaigns, only: [:index]
  before_action :get_campaign, only: [:analytics, :edit, :destroy, :update, :toggle_state]
  before_action :verify_identity, only: [:analytics, :edit, :destroy, :update, :toggle_state]
  before_action :campaign_not_active, only: [:edit]

  def index
  end

  def provider_index
    if params[:q] == "review"
      @board_campaigns = BoardsCampaigns.where(board_id: @project.boards.enabled.pluck(:id), campaign_id: Campaign.active.joins(:boards).merge(@project.boards).uniq.pluck(:id)).in_review
    elsif params[:bilbo].present?
      @board_campaigns = BoardsCampaigns.where(board_id: @project.boards.enabled.where(name: params[:bilbo]), campaign_id: Campaign.active.joins(:boards).merge(@project.boards).uniq.pluck(:id)).approved
    else
      @board_campaigns = BoardsCampaigns.where(board_id: @project.boards.enabled.pluck(:id), campaign_id: Campaign.active.joins(:boards).merge(@project.boards).uniq.pluck(:id)).approved
    end
  end

  def analytics
  end

  def edit
    @ads = @project.ads.active.select{ |ad| ad.multimedia.any? }
    @campaign_boards =  @campaign.boards.enabled.collect { |board| ["#{board.address} - #{board.face}", board.id, { 'data-price': board.cycle_price } ] }
    @campaign.starts_at = @campaign.starts_at.to_date rescue ""
    @campaign.ends_at = @campaign.ends_at.to_date rescue ""
  end

  def toggle_state
    @campaign.with_lock do
      @success = @campaign.update(state: !@campaign.state)
    end
  end


  def update
    respond_to do |format|
      if @campaign.update_attributes(campaign_params.merge(state: true))
        # move campaign to in review since it was changed
        @campaign.set_in_review
        # Create a notification per project
        @campaign.boards.includes(:project).map(&:project).uniq.each do |provider|
          create_notification(recipient_id: provider.id, actor_id: @campaign.project.id,
                              action: "created", notifiable: @campaign)
        end
        format.html {
          flash[:success] = I18n.t('campaign.action.updated')
          redirect_to campaigns_path
         }
        format.json { head :no_content }
      else
        format.html {
          flash[:error] = @campaign.errors.full_messages.first
          redirect_to campaigns_path }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @campaign = Campaign.new(create_params)
    if @campaign.save
      flash[:success] = I18n.t('campaign.action.saved')
    else
      flash[:error] = I18n.t('campaign.errors.no_save')
    end
    redirect_to edit_campaign_path(@campaign)
  end

  def destroy
    if !@campaign.state?
      @campaign.inactive!
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

  private
  def campaign_params
    @campaign_params = params.require(:campaign).permit(:name, :description, :boards, :ad_id, :starts_at, :ends_at, :budget).merge(:project_id => @project.id)
    @campaign_params[:boards] = Board.where(id: @campaign_params[:boards].split(",").reject(&:empty?)) if @campaign_params[:boards].present?
    @campaign_params[:starts_at] = nil if @campaign_params[:starts_at].nil?
    @campaign_params[:ends_at] = nil if @campaign_params[:ends_at].nil?
    @campaign_params[:budget] = @campaign_params[:budget].tr(",","").to_f
    @campaign_params
  end

  def create_params
    @campaign_params = params.require(:campaign).permit(:name, :description).merge(:project_id => @project.id)
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
end
