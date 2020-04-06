class CampaignsController < ApplicationController
  access user: {except: [:review, :approve_campaign, :deny_campaign, :provider_index]}, provider: :all
  before_action :get_campaigns, only: [:index]
  before_action :get_campaign, only: [:analytics, :edit, :destroy, :update, :toggle_state]
  before_action :verify_identity, only: [:analytics, :edit, :destroy, :update, :toggle_state]
  before_action :campaign_not_active, only: [:edit]

  def index
  end

  def provider_index

  end

  def analytics
  end

  def edit
    @ads = @project.ads.active.select{ |ad| ad.multimedia.any? }
    @campaign_boards =  @campaign.boards.collect { |board| ["#{board.address} - #{board.face}", board.id] }
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
      if @campaign.update_attributes(campaign_params.merge(state: true, provider_campaign: current_user.is_provider?))
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
    @campaign = Campaign.new(campaign_params)
    if @campaign.save
      flash[:success] = I18n.t('campaign.action.saved')
    else
      flash[:error] = I18n.t('campaign.errors.no_save')
    end
    redirect_to edit_campaign_path(@campaign)
  end

  def destroy
    if @campaign.inactive!
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
          flash[:error] = @campaign.errors.full_messages.first
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
    @campaign_params
  end

  def get_campaigns
    @campaigns = @project.campaigns.includes(:boards, :impressions).active
  end

  def get_campaign
    @campaign = Campaign.includes(:boards, :impressions).where(project: @project).friendly.find(params[:id])
  end

  def verify_identity
    redirect_to campaigns_path if not @campaign.project.users.include? current_user.id
  end

  def campaign_not_active
    if @campaign.state
      flash[:error] = I18n.t('campaign.errors.cant_update_when_active')
      redirect_back fallback_location: root_path
    end
  end
end
