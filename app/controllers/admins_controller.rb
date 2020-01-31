class AdminsController < ApplicationController
  access admin: :all

  def index
  end

  def new
  end

  def show_users
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

  def show

  end

  def create
  end

  private
end
