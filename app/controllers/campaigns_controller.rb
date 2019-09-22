class CampaignsController < ApplicationController
  access user: :all, provider: {except: [:new]}
  before_action :get_campaigns, only: [:index]
  before_action :get_campaign, only: [:analytics, :edit, :destroy, :update, :toggle_state]
  before_action :verify_identity, only: [:analytics, :edit, :destroy, :update, :toggle_state]

  def index
    redirect_to root_path
  end

  def analytics
  end

  def edit
    @ads = current_user.ads
    @campaign_boards =  @campaign.boards.collect { |board| ["#{board.address} - #{board.face}", board.id] }
    @campaign.starts_at = @campaign.starts_at.to_date rescue ""
    @campaign.ends_at = @campaign.ends_at.to_date rescue ""
  end

  def toggle_state
    @campaign.toggle(:state).save
  end

  def update
    respond_to do |format|
      if @campaign.update_attributes(campaign_params)
        format.html { redirect_to root_path, notice: 'Campaign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @campaign = Campaign.new(campaign_params)
    if @campaign.save
      flash[:success] = "Campaign saved"
    else
      flash[:error] = "Could not save campaign"
    end
    redirect_to edit_campaign_path(@campaign)
  end

  def destroy
    @campaign.destroy

    respond_to do |format|
      format.html { redirect_to campaigns_path }
      format.json { head :no_content }
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
    @campaigns = current_user.campaigns
  end

  def get_campaign
    @campaign = Campaign.includes(:boards).friendly.find(params[:id])
  end

  def verify_identity
    redirect_to campaigns_path if @campaign.user != current_user
  end
end
