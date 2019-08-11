class BoardsController < ApplicationController
  access [:provider, :admin, :user] => [:get_info, :show, :index], provider: [:owned]
  # before_action :get_all_boards, only: :show

  def index
  end

  # provider boards
  def owned
  end

  def get_info
    if params[:lat].present?
      lat = params[:lat].to_f
      lng = params[:lng].to_f
    else #using select
      @board = Board.find(params[:id])
      lat = @board.lat
      lng = @board.lng
    end
    @boards = Board.where(status: "enabled", lat: (lat - 0.00001)..(lat + 0.00001), lng: (lng - 0.00001)..(lng + 0.00001))

  end

  private
  def get_all_boards
    @boards = Board.enabled.pluck(:id, :latitude, :longitude).to_json
  end
end
