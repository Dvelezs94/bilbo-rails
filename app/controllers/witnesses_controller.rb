class WitnessesController < ApplicationController
  before_action :get_campaign, only:[:create, :validate_weekly_generation]
  before_action :validate_weekly_generation, only:[:create]
  before_action :set_witness, only: [:show, :edit, :update, :destroy, :evidences_witness_modal]
  access all: [ :new, :edit, :create, :update, :destroy], user: :all

  def new
    @witness = Witness.new
  end

  def edit
  end

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

  def update
    @witness.update(witness_params)
    if @witness.save
      redirect_to edit_witness_url(@witness)
    else
      redirect_to edit_witness_url(@witness)
    end
  end

  def evidences_witness_modal
    @evidences = @witness.evidences.map{|evidence| evidence}
  end

  def validate_weekly_generation
    if @campaign.witnesses.present?
      @campaign.witnesses.where(created_at: 1.day.ago..Time.zone.now).exists?
      flash[:error] = I18n.t('witness.validate_weekly_generation')
      redirect_to  analytics_campaign_path(@campaign.slug)
    end
  end
  private

  def get_campaign
    @campaign= Campaign.friendly.find(create_params[:campaign_id])
  end

  def get_witness
    @witness= Witness.friendly.find(witness_params[:id])
  end

  def get_all_witnesses
    @witnesses = @campaign.witnesses.order(created_at: :desc)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_witness
    @witness = Witness.friendly.find(params[:id])
  end

  def get_campaign
    @campaign = Campaign.friendly.find(witness_params[:campaign_id])
  end

  def witness_params
    params.require(:witness).permit(:status, :campaign_id, :slug)
  end
end
