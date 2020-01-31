class CampaignsController < ApplicationController
  access user: {except: [:review, :approve_campaign, :deny_campaign]}, provider: {except: [:new]}
  before_action :get_campaigns, only: [:index]
  before_action :get_campaign, only: [:analytics, :edit, :destroy, :update, :toggle_state]
  before_action :verify_identity, only: [:analytics, :edit, :destroy, :update, :toggle_state]
  before_action :campaign_not_active, only: [:edit]

  def index
  end

  def analytics
  end

  # Methods for the provider to either approve or deny a campaign
  def review
    # get campaigns of the providers boards that are in "in_review" state
  end

  def approve_campaign
    if @campaign.approved!
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
  # end provider methods

  def edit
    @ads = current_user.ads.active.select{ |ad| ad.multimedia.any? }
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
      if @campaign.update_attributes(campaign_params)
        format.html {
          flash[:success] = I18n.t('campaign.action.updated')
          redirect_to root_path
         }
        format.json { head :no_content }
      else
        format.html {
          flash[:error] = @campaign.errors.full_messages.first
          redirect_to root_path }
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
    if @campaign.update(status: "deleted")
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
    @campaign_params = params.require(:campaign).permit(:name, :description, :boards, :ad_id, :starts_at, :ends_at, :budget).merge(:user_id => current_user.id)
    @campaign_params[:boards] = Board.where(id: @campaign_params[:boards].split(",").reject(&:empty?)) if @campaign_params[:boards].present?
    @campaign_params[:starts_at] = nil if @campaign_params[:starts_at].nil?
    @campaign_params[:ends_at] = nil if @campaign_params[:ends_at].nil?
    @campaign_params
  end

  def get_campaigns
    @campaigns = current_user.campaigns.where.not(status: "deleted")
  end

  def get_campaign
    @campaign = Campaign.includes(:boards).friendly.find(params[:id])
  end

  def verify_identity
    redirect_to campaigns_path if @campaign.user != current_user
  end

  def campaign_not_active
    if @campaign.state
      flash[:error] = I18n.t('campaign.errors.cant_update_when_active')
      redirect_back fallback_location: root_path
    end
  end
end
