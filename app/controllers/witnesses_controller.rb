class WitnessesController < ApplicationController
  access [:user, :provider] => :all
  before_action :validate_user_present, only:[:get_campaign, :create, :validate_weekly_generation]
  before_action :get_campaign, only:[:create, :validate_weekly_generation]
  before_action :validate_weekly_generation, only:[:create]
  before_action :set_witness, only: [:evidences_witness_modal, :evidences_dashboard_provider]

  def create
    if @campaign.state
      if @campaign.board_campaigns.present? && @campaign.board_campaigns.approved.present?
        @witness = Witness.new(witness_params)
        if @witness.save
          flash[:success] = I18n.t('witness.succesfully')
          redirect_to analytics_campaign_path(@campaign.slug)
          else
            flash[:error] = I18n.t('witness.error')
            redirect_to analytics_campaign_path(@campaign.slug)
          end
        else
          flash[:error] = I18n.t('witness.without_bilbos')
          redirect_to analytics_campaign_path(@campaign.slug)
        end
    else
      flash[:error] = I18n.t('witness.campaign_active')
      redirect_to analytics_campaign_path(@campaign.slug)
    end
  end

  def evidences_witness_modal
    @evidences = @witness.evidences.map{|evidence| evidence}
  end

  def evidences_dashboard_provider
    render 'evidences/evidences_dashboard'
  end

  private
  def validate_weekly_generation
    if @campaign.witnesses.present?
      @campaign.witnesses.where(created_at: 1.day.ago..Time.zone.now).exists?
      flash[:error] = I18n.t('witness.validate_weekly_generation')
      redirect_to  analytics_campaign_path(@campaign.slug)
    end
  end

  def validate_user_present
    redirect_to user_session_path if !current_user.present?
  end

  def get_campaign
    @campaign = @project.campaigns.friendly.find(witness_params[:campaign_id])
  end

  def get_all_witnesses
    @witnesses = @campaign.witnesses.order(created_at: :desc)
  end

  def set_witness
    @witness = Witness.friendly.find(params[:id])
  end

  def witness_params
    params.require(:witness).permit(:status, :campaign_id, :slug)
  end
end
