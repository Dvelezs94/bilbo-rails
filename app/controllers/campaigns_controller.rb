class CampaignsController < ApplicationController
  access user: :all, provider: {except: [:new]}
  before_action :get_campaigns, only: [:index]
  before_action :get_campaign, only: [:analytics, :edit, :destroy, :update, :toggle_state]
  before_action :verify_identity, only: [:analytics, :edit, :destroy, :update, :toggle_state]

  def index
  end

  def analytics
  end

  def edit
    @ads = current_user.ads
  end

  def toggle_state
    @campaign.toggle(:state).save
  end

  def update
    respond_to do |format|
      if @campaign.update_attributes(campaign_params)
        format.html { redirect_to @campaign, notice: 'Campaign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "show" }
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
    params.require(:campaign).permit(:name, :description).merge(:user_id => current_user.id)
  end

  def get_campaigns
    @campaigns = current_user.campaigns
  end

  def get_campaign
    @campaign = Campaign.friendly.find(params[:id])
  end

  def verify_identity
    redirect_to campaigns_path if @campaign.user != current_user
  end
end
