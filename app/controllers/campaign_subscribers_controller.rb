class CampaignSubscribersController < ApplicationController
  access user: :all, provider: :all
  before_action :verify_admins
  before_action :get_campaign
  before_action :get_subscriber, only: [:update, :destroy]


  def edit
    @subscribers = @campaign.subscribers
  end

  def create
    @subscriber = @campaign.subscribers.new(subscriber_params)
    if @subscriber.save
      flash[:success] = t("campaign.subscribers.added")
    else
      flash[:error] = @subscriber.errors.full_messages.to_sentence.split[1..].join(' ')
    end
  end

  def update
    if @subscriber.update(subscriber_params)
      flash[:success] = t("campaign.subscribers.updated")
    else
      flash[:error] = t("campaign.subscribers.could_not_update")
    end
    redirect_to root_path
  end

  def destroy
    if @subscriber.destroy
      flash[:success] = t("campaign.subscribers.deleted")
    else
      flash[:error] = t("campaign.subscribers.could_not_delete")
    end
    render "create"
  end

  private
  def get_campaign
    @campaign = @project.campaigns.friendly.find(params[:campaign_id])
    puts @campaign.name
  end

  def get_subscriber
    @subscriber = @campaign.subscribers.find(params[:id])
  end

  def subscriber_params
    params.require(:campaign_subscriber).permit(:name, :phone)
  end

  # only admins can add subscribers
  def verify_admins
    if not @project.admins.include? current_user.id
      raise_not_found
    end
  end
end
