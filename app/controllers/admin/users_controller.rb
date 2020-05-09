class Admin::UsersController < ApplicationController
  access admin: :all
  before_action :get_user, only: [:fetch, :verify]

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

  def verify
    @user_verification = @user.verifications.where(status: ["pending", "accepted"]).first
    if @user.update(verified: true) && @user_verification.accepted!
      flash[:success] = "User verified"
    else
      flash[:error] = "Could not verfy user"
    end
    redirect_to admin_users_path(role: "user")
  end

  private

  def get_user
    @user = User.find(params[:id])
  end
end
