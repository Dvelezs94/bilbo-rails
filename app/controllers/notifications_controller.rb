class NotificationsController < ApplicationController
  #before_action :set_notification, only: [:show, :edit, :update, :destroy]
  access user: :all

  # GET /notifications
  def index
    @notifications = @project.notifications.page(params[:page])
  end

  # clears all notifications
  def clear
    @project.notifications.unread.each { |notif|  notif.read! }
    respond_to do |format|
      format.html{head :no_content}
    end
  end
end
