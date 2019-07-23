class BoardsController < ApplicationController
  before_action :authenticate_user!
  # before_action :get_all_boards, only: :show

  def show
  end

  def get_info
    @board = Board.find(params[:id])
    # respond_to do |format|
    #   msg = { status: "ok", description: @board.description, avg_daily_views: @board.avg_daily_views, width: @board.width, height: @board.height,
    #   duration: @board.duration, face: @board.face }
    #   format.json  { render :json => msg } # don't do msg.to_json
    # end
  end

  private
  def get_all_boards
    @boards = Board.enabled.pluck(:id, :latitude, :longitude).to_json
  end
end
