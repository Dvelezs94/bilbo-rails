class BoardsController < ApplicationController
  access [:provider, :admin, :user] => [:index], provider: [:statistics, :owned, :regenerate_access_token, :regenerate_api_token], all: [:show, :map_frame, :get_info], admin: [:toggle_status, :admin_index, :create, :edit, :update, :delete_image]
  # before_action :get_all_boards, only: :show
  before_action :get_board, only: [:statistics, :show, :regenerate_access_token, :regenerate_api_token, :toggle_status, :update, :delete_image]
  before_action :restrict_access, only: :show
  before_action :validate_identity, only: [:regenerate_access_token, :regenerate_api_token]
  before_action :allow_iframe_requests, only: :map_frame

  def index
    respond_to do |format|
    format.js { #means filter is used
      get_boards
      if params[:cycle_price].present?
        @boards = @boards.select{ |board| board.cycle_price <= params[:cycle_price].to_f }
        @boards = Board.where(id: @boards)
      end
      @boards = @boards.where("height > ?", params[:min_height]) if params[:min_height].present?
      @boards = @boards.where("width > ?", params[:min_width]) if params[:min_width].present?
      @boards = @boards.where(category: params[:category]) if params[:category].present?
      @boards = @boards.where(social_class: params[:social_class]) if params[:social_class].present?
     }
    format.html {
      get_boards
     }
   end
  end

  def edit
    @board = Board.friendly.find(params[:id])
  end

  def delete_image
    @board.with_lock do
      image = @board.images.select { |im| im.signed_id == params[:signed_id] }[0]
      image.purge
    end
  end

  def update
    @success = @board.update(board_params)
    if @success
      flash[:success] = "Bilbo actualizado con éxito"
      redirect_to edit_board_path(@board.slug)
    end
  end

  def admin_index
  end

  def map_frame
  end

  # provider boards
  def owned
    @boards = @project.boards.search(params[:search_board]).order(created_at: :desc).page(params[:page])
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
    if @board.update(status: params[:status])
      flash[:success] = "Board status updated to: #{params[:status]}"
    else
      flash[:error] = "Error trying to update board #{@board.name}"
    end
    redirect_to request.referer
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
    @bilbo_top = Board.top_campaigns(@board, 3.months.ago..Time.now, 2).first(4)
    @percentage = @bilbo_top.each_with_index.map{|p, i| p[1]}.sum
    if @bilbo_top.length >= 1
      @percentage_top_1 = '%.2f' %(@bilbo_top[0][1].to_f * 100 / @percentage)
    end
    if @bilbo_top.length >= 2
      @percentage_top_2 = '%.2f' %(@bilbo_top[1][1].to_f * 100 / @percentage)
    end
    if @bilbo_top.length >= 3
      @percentage_top_3 = '%.2f' %(@bilbo_top[2][1].to_f * 100 / @percentage)
    end
    if @bilbo_top.length == 4
      @percentage_top_4 = '%.2f' %(@bilbo_top[3][1].to_f * 100 / @percentage)
    end
  end


  private

  def board_params
    params.require(:board).permit(:project_id,
                                  :name,
                                  :avg_daily_views,
                                  :width,
                                  :height,
                                  :lat,
                                  :lng,
                                  :address,
                                  :category,
                                  :start_time,
                                  :end_time,
                                  :face,
                                  :base_earnings,
                                  :social_class,
                                  :default_image,
                                  images: []
                                  )
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

  def get_boards
    if current_user.is_provider?
      @boards = @project.boards
    else
      @boards = Board.enabled
    end
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
    if current_user.is_admin?
      @board = Board.friendly.find(params[:id])
    else
      @board = @project.boards.friendly.find(params[:id])
    end
  end

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end
end
