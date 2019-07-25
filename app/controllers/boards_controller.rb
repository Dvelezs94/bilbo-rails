class BoardsController < ApplicationController
  access [:provider, :admin, :user] => [:get_info, :show], provider: [:owned]
  # before_action :get_all_boards, only: :show

  def show
  end

  # provider boards
  def owned
  end

  def get_info
    lat = params[:lat].to_f
    lng = params[:lng].to_f
    # @board = Board.find(params[:id])
    @boards = Board.where(status: "enabled", lat: (lat - 0.00001)..(lat + 0.00001), lng: (lng - 0.00001)..(lng + 0.00001))
  end

  private
  def get_all_boards
    @boards = Board.enabled.pluck(:id, :latitude, :longitude).to_json
  end
end
