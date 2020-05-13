class VerificationsController < ApplicationController
  access user: :all
  before_action :verify_previous_verification, only: :create


  def create
    @verification = Verification.new(verification_params)
    if @verification.save
      flash[:success] = "Te contactaremos en un máximo de 48 horas para verificar la información"
    else
      flash[:error] = "Error, contacta al soporte en el centro de ayuda"
    end
    redirect_to root_path
  end

  private
  def verification_params
    params.require(:verification).permit(:name,
                                         :official_id,
                                         :business_name,
                                         :street_1,
                                         :street_2,
                                         :city,
                                         :state,
                                         :zip_code,
                                         :country,
                                         :rfc,
                                         :business_code,
                                         :official_business_name,
                                         :website,
                                         :phone,
                                         :status).merge(user_id: current_user.id)
  end
  # Make sure user does not send many verifications
  def verify_previous_verification
    raise_not_found if current_user.verifications.pending.present?
  end
end