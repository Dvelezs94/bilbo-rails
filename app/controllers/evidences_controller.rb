class EvidencesController < ApplicationController
  before_action :set_evidence, only: [:new_evidence, :update]
  before_action :check_owner, only: [:new_evidence, :update]
  access [:provider] => [:new_evidence, :update, :set_evidence]

  def new_evidence
    render 'new_evidence'
  end

  def update
    @evidence.update(evidence_params)
    if  @evidence.multimedia.present?
      @evidence.multimedia_derivatives!
    end
    if @evidence.save
      @success_message = I18n.t('evidence.succesfully')
    else
      @error_message = I18n.t('evidence.error')
    end
    render 'update'
  end

  def check_owner
    raise_not_found if @project.id != @evidence.board.project_id
  end


  private
  def set_evidence
    @evidence = Evidence.find(params[:id])
  end

  def evidence_params
    params.require(:evidence).permit(:id, :multimedia, :board_id)
  end
end
