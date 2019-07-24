class BoardsController < ApplicationController
  before_action :authenticate_user!
  # before_action :get_all_boards, only: :show

  def show
  end

  def get_info
    lat = params[:lat].to_f
    lng = params[:lng].to_f
    # @board = Board.find(params[:id])
    @boards = Board.where(status: "enabled", lat: (lat - 0.00001)..(lat + 0.00001), lng: (lng - 0.00001)..(lng + 0.00001))
    p @boards
  end

  private
  def get_all_boards
    @boards = Board.enabled.pluck(:id, :latitude, :longitude).to_json
  end
end
