class BoardsController < ApplicationController
  access [:provider, :admin, :user] => [:get_info, :index], provider: [:owned, :regenerate_access_token], all: [:show]
  # before_action :get_all_boards, only: :show
  before_action :get_board, only: [:show, :regenerate_access_token]
  before_action :restrict_access, only: :show
  before_action :validate_identity, only: :regenerate_access_token
  before_action :get_provider_boards, only: :owned

  def index
  end

  # provider boards
  def owned
  end

  def show
  end

  def get_info
    if params[:lat].present?
      lat = params[:lat].to_f
      lng = params[:lng].to_f
    else #using select
      @board = Board.find(params[:selected_id])
      lat = @board.lat
      lng = @board.lng
    end
    @boards = Board.where(status: "enabled", lat: (lat - 0.00001)..(lat + 0.00001), lng: (lng - 0.00001)..(lng + 0.00001))

  end

  # Regenerates access token when needed
  def regenerate_access_token
    if @board.update_attribute(:access_token, SecureRandom.hex)
      flash[:success] = "Token was generated"
    else
      flash[:alert] = "Failed to create token"
    end
    redirect_to root_path
  end

  private
  def get_all_boards
    @boards = Board.enabled.pluck(:id, :latitude, :longitude).to_json
  end

  def get_provider_boards
    @boards = current_user.boards
  end

  # validate identity when trying to maange the boards
  def validate_identity
    redirect_to root_path, alert: "Access denied" if @board.user != current_user
  end

  #validate access token when trying to access a board
  def restrict_access
    board_access_token = Board.find_by_access_token(params[:access_token])
    redirect_to root_path unless board_access_token == @board
  end

  def get_board
    @board = Board.friendly.find(params[:id])
  end
end
