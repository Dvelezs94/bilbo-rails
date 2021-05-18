class WitnessesController < ApplicationController
  before_action :set_witness, only: [:show, :edit, :update, :destroy, :evidences_witness_modal]
  before_action :get_campaign, only:[:create]
  access all: [:index, :show, :new, :edit, :create, :update, :destroy], user: :all

  # GET /witnesses
  def index
    @witnesses = Witness.all
  end

  # GET /witnesses/1
  def show
  end

  # GET /witnesses/new
  def new
    @witness = Witness.new
  end

  # GET /witnesses/1/edit
  def edit
  end

  # POST /witnesses
  def create
  if @campaign.board_campaigns.present?
    @witness = Witness.new(witness_params)
    if @witness.save
      flash[:success] = "Testigos solicitados con éxito"
      redirect_to analytics_campaign_path(@campaign.slug)
      else
        flash[:error] = "Error"
        redirect_to analytics_campaign_path(@campaign.slug)
      end
    else
      flash[:error] = "Su campaña no cuenta con bilbos"
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

  private

  def get_campaign
    @campaign= Campaign.find(create_params[:campaign_id])
  end

  def get_witness
    @witness= Witness.find(witness_params[:id])
  end

  def get_all_witnesses
    @witnesses = @campaign.witnesses.order(created_at: :desc)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_witness
    @witness = Witness.find(params[:id])
  end

  def get_campaign
    @campaign = Campaign.find(witness_params[:campaign_id])
  end

  # Only allow a trusted parameter "white list" through.
  def witness_params
    params.require(:witness).permit(:status, :campaign_id, evidences_attributes:[:id, :multimedia, :_destroy, :board_id ])
  end
end
