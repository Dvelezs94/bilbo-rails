class BoardsController < ApplicationController
  access [:provider, :admin, :user] => [:get_info, :index, :create], provider: [:statistics, :owned, :regenerate_access_token, :regenerate_api_token, :create], all: [:show], admin: [:toogle_status, :admin_index]
  # before_action :get_all_boards, only: :show
  before_action :get_board, only: [:show, :regenerate_access_token, :regenerate_api_token]
  before_action :restrict_access, only: :show
  before_action :validate_identity, only: [:regenerate_access_token, :regenerate_api_token]
  before_action :get_provider_boards, only: :owned
  
  def index
  end

  def admin_index
  end

  # provider boards
  def owned
  end

  def show
      if !@board.connected?
      @active_campaigns = @board.active_campaigns
      # Set api key cookie
      cookies.signed[:api_key] = {
        value: @board.api_token,
        path: request.env['PATH_INFO']
      }
    else
      redirect_to root_path
    end
  end


  def create
    @board = Board.new(board_params)
    if @board.save
      flash[:success] = "Board saved"
    else
      flash[:error] = "Could not save board"
    end
    redirect_to root_path
  end

  # Admin action to toggle the status of a board
  def toggle_status
  end

  # this gets called when a board is selected in the map
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

  def regenerate_api_token
    if @board.update_attribute(:api_token, SecureRandom.hex)
      flash[:success] = "Token was generated"
    else
      flash[:alert] = "Failed to create token"
    end
    redirect_to root_path
  end

  # statistics of a singular board
  def statistics
  end

  private

  def board_params
    @campaign_params = params.require(:board).permit(:name,
                                                        :avg_daily_views,
                                                        :width,
                                                        :height,
                                                        :lat,
                                                        :lng,
                                                        :duration,
                                                        :address,
                                                        :category,
                                                        :face,
                                                        :base_earnings,
                                                        images: []).merge(:user_id => User.find_by_email(:email))
  end

  def get_all_boards
    @boards = Board.enabled.pluck(:id, :latitude, :longitude).to_json
  end

  # method used to get all boards for the admin dashboard
  def get_all_boards_admin
    @enabled_boards = Board.enabled
    @disabled_boards = Board.disabled
    @in_review_boards = Board.in_review
    @banned_boards = Board.banned
  end

  def get_provider_boards
    @boards = current_user.boards.page(params[:page])
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
