class VerificationsController < ApplicationController
  access user: :all
  before_action :verify_previous_verification, only: :create


  def create
    @verification = Verification.new(verification_params)
    if @verification.save
      SlackNotifyWorker.perform_async("Nueva verificación pendiente del usuario #{@verification.user.email}.")
      flash[:success] = "Te contactaremos en un máximo de 48 horas para verificar la información"
    else
      flash[:error] = "Error, contacta al soporte en el centro de ayuda"
    end
    if current_user.is_admin?
      redirect_to admin_users_path(role: "user")
    else
      redirect_to root_path
    end
  end

  private
  def verification_params
    params.require(:verification).permit(:user_id,
                                         :name,
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
                                         :status)
  end
  # Make sure user does not send many verifications
  def verify_previous_verification
    if current_user.is_admin?
      user =  User.find(verification_params[:user_id])
      if user.verifications.pending.present?
        flash[:notice] = "Ya tienes una verificatión en proceso."
        SlackNotifyWorker.perform_async("Nueva verificación pendiente del usuario #{user.email}.")
        redirect_to admin_users_path(role: "user")
      end
    elsif current_user.verifications.pending.present?
      flash[:notice] = "Ya tienes una verificatión en proceso."
      # resend notification to admins
      SlackNotifyWorker.perform_async("Nueva verificación pendiente del usuario #{current_user.email}.")
      redirect_to root_path
    end
  end
end
