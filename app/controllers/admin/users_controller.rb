class Admin::UsersController < ApplicationController
  include MailerHelper
  access admin: :all, all: [:stop_impersonating, :toggle_show_recent_campaigns]
  before_action :get_user, only: [:fetch, :verify, :deny, :update_credit, :increase_credits, :impersonate, :toggle_ban, :toggle_show_recent_campaigns]


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
    search = "%#{params[:search]}%"
    if search.present?
      @users = User.where(roles: user_role).where("name LIKE ? OR email LIKE ?", search, search )
    else
      @users = User.where(roles: user_role)
    end
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
        flash[:success] = "Credits updated"
      else
        flash[:error] = "Could not update"
      end
      redirect_to admin_users_path(role: "user")
  end

  def toggle_ban
    if @user.toggle_ban!
      flash[:success] = "User #{@user.name} updated"
    else
      flash[:error] = "Could not update #{@user.name}"
    end
    redirect_to admin_users_path
  end

  def increase_credits
    if @user.add_credits(params[:total])
      flash[:success] = I18n.t("payments.purchase_success", credits_number: params[:total])
    else
      flash[:error] = @user.errors
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

  # impersonates

  def impersonate
    impersonate_user(@user)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to root_path
  end
  # end impersonates

  def sync_sendgrid_contacts
    SyncEmailContactsWorker.perform_async
    redirect_to admin_users_path(role: "user")
    flash[:success] = "Contactos agregandose"
  end

  def toggle_show_recent_campaigns
    @user.update(show_recent_campaigns: !@user.show_recent_campaigns)
    redirect_to campaigns_path
  end

  private

  def get_user
    @user = User.find(params[:id])
  end

end
