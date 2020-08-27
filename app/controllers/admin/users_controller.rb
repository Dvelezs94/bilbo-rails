class Admin::UsersController < ApplicationController
  include MailerHelper
  access admin: :all
  before_action :get_user, only: [:fetch, :verify, :deny, :update_credit, :increase_credits]

  def index
    case params[:role]
    when "user"
      user_role = :user
    when "provider"
      user_role = :provider
    when "support"
      user_role = :support
    else
      user_role = :user
    end
    @users = User.where(roles: user_role)
  end

  def fetch
    @user_verification = @user.verifications.where(status: ["pending", "accepted"]).first
    respond_to do |format|
        format.js
    end
  end

  # used to edit credit limit purchase per day
  def update_credit
      if @user.update(credit_limit: params[:credit_limit])
        flash[:success] = "creadits changed"
      else
        flash[:error] = "Could not update"
      end
      redirect_to admin_users_path(role: "user")
  end


  def increase_credits
    if @user.add_credits(params[:total])
      flash[:success] = I18n.t("payments.purchase_success", credits_number: params[:total])
    else
      puts "x" * 500
      puts @user.errors.full_messages
      flash[:error] = @user.errors.full_messages.to_sentence
    end
    redirect_to admin_users_path(role: "user")
  end

  def verify
    @user_verification = @user.verifications.where(status: ["denied", "pending", "accepted"]).first
    if @user_verification.accepted! && @user.update(verified: true)
      flash[:success] = "User verified"
      accept_verification_email
    else
      flash[:error] = "Could not verfy user"
    end
    redirect_to admin_users_path(role: "user")
  end

  def deny
    @user_verification = @user.verifications.where(status: ["pending", "accepted", "denied"]).first
    if @user_verification.denied! && @user.update(verified: false)
      flash[:success] = "User denied"
      @user.verifications.first.destroy
      if params[:message].present?
        deny_verification_email(params[:message])
      else
        text = I18n.t('verification.message_deny')
        deny_verification_email(text)
      end
    else
      flash[:error] = I18n.t('campaign.errors.no_save')
    end
  redirect_to admin_users_path(role: "user")
 end

 def accept_verification_email
     @subject   = I18n.t('verification.subject')
     @title     = I18n.t('verification.title')
     @greeting  = @subject
     @message   = I18n.t('verification.message')
     @link      = campaigns_url(credits: "true")
     @link_text = I18n.t('verification.link_text')
     generic_mail(subject= @subject, title= @title, greeting= @greeting, message= @message, receiver= @user.email, link= @link, link_text= @link_text)
   end

   def deny_verification_email(text)
       @subject   = I18n.t('verification.subject_deny')
       @title     = I18n.t('verification.title_deny')
       @greeting  = @subject
       @message   = text
       generic_mail(subject= @subject, title= @title, greeting= @greeting, message= @message, receiver= @user.email)
     end

  private

  def get_user
    @user = User.find(params[:id])
  end
end
