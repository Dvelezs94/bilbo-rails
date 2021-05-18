class EvidencesController < ApplicationController
  before_action :set_evidence, only: [:new_evidence, :show, :edit, :update, :destroy]
  access all: [:index, :show, :new, :edit, :create, :update, :destroy], user: :all

  # GET /Evidences
  def index
    @Evidences = Evidence.all
  end

  def new_evidence

  end

  # GET /Evidences/1
  def show
  end

  # GET /Evidences/new
  def new
    @evidence = Evidence.new
  end

  # GET /Evidences/1/edit
  def edit
  end

  # POST /Evidences
  def create
    evidence = Evidence.new(evidence_params)
    if evidence.save
      flash[:success] = "Evidencia creada con éxito"
      #redirect_to analytics_campaign_path(@campaign.slug)
      else
        flash[:error] = "Error"
        #redirect_to analytics_campaign_path(@campaign.slug)
      end
  end

  def update
    @evidence.update(evidence_params)
    if  @evidence.multimedia.present?
      @evidence.multimedia_derivatives!
    end
    if @evidence.save

    else
    end
  end

    private
  # Use callbacks to share common setup or constraints between actions.
  def set_evidence
    @evidence = Evidence.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def evidence_params
    params.require(:evidence).permit(:id, :multimedia, :board_id)
  end
end
