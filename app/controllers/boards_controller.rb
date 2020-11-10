class BoardsController < ApplicationController
  access [:provider, :admin, :user] => [:index], [:user, :provider] => [:owned, :statistics, :index], provider: [ :regenerate_access_token, :regenerate_api_token], all: [:show, :map_frame, :get_info, :requestAdsRotation], admin: [:toggle_status, :admin_index, :create, :edit, :update, :delete_image, :delete_default_image]
  # before_action :get_all_boards, only: :show
  before_action :get_board, only: [:statistics, :requestAdsRotation, :show, :regenerate_access_token, :regenerate_api_token, :toggle_status, :update, :delete_image, :delete_default_image]
  before_action :restrict_access, only: [:show]
  before_action :validate_identity, only: [:regenerate_access_token, :regenerate_api_token]
  before_action :validate_just_api_token, only: [:requestAdsRotation]
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

  def delete_default_image
    @board.with_lock do
      element = @board.default_images.select { |di| di.signed_id == params[:signed_id] }[0]
      element.purge
    end
  end

  def requestAdsRotation
    @board.with_lock do
      if @board.should_update_ads_rotation?
        errors = @board.update_ads_rotation
        return head(:internal_server_error) if errors.any?
        ActionCable.server.broadcast(
          @board.slug,
          action: "update_rotation",
          ads_rotation: @board.add_bilbo_campaigns.to_s,
          remaining_impressions: @board.get_user_remaining_impressions.to_s
        )
      end
    end
  end

  def update
    @success = @board.update(board_params.merge(admin_edit: true))
    #check if needs to deactivate campaigns when updates from admin form
    if @success
      active_provider_campaigns = @board.active_campaigns("provider").sort_by { |c| (c.clasification == "per_hour")? 0 : 1}
      deactivated = 0
      active_provider_campaigns.each do |cpn|
        err = @board.update_ads_rotation(true)
        break if err.empty?
        cpn.update!(state: false) #after cp turns off it updates rotations and broadcasts to all boards (including this board)
        deactivated +=1
      end
      if deactivated > 0
        flash[:notice] = I18n.t("bilbos.campaigns_disabled",number: deactivated)
      end
        flash[:success] = I18n.t("bilbos.update_success")
    else
      flash[:error] = @board.errors.full_messages.first
    end
    redirect_to edit_board_path(@board.slug)
  end

  def admin_index
  end

  def map_frame
    get_boards
  end

  # provider boards
  def owned
    @boards = @project.boards.search(params[:search_board]).order(created_at: :desc).page(params[:page])
  end

  def show
      if !@board.connected?
      errors = @board.update_ads_rotation if @board.should_update_ads_rotation?
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
                                  :utc_offset,
                                  :duration,
                                  :images_only,
                                  :extra_percentage_earnings,
                                  :mac_address,
                                  :keep_old_cycle_price_on_active_campaigns,
                                  :displays_number,
                                  images: [],
                                  default_images: []
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
    if user_signed_in? && current_user.is_provider?
      @boards = @project.boards
    else
      @boards = Board.enabled
    end
  end

  # validate identity when trying to maange the boards
  def validate_identity
    redirect_to root_path, alert: "Access denied" if @board.user != current_user
  end
  def validate_just_api_token
    redirect_to root_path if @board.api_token != params[:api_token]
  end

  #validate access token when trying to access a board
  def restrict_access
    board_access_token = Board.find_by_access_token(params[:access_token])
    if @board.mac_address.present?
      if params[:mac_address].present?
        board_mac_address = params[:mac_address].downcase
        redirect_to root_path unless (board_mac_address == @board.mac_address) && (board_access_token == @board)
      else
        redirect_to root_path
      end
    else
      redirect_to root_path unless board_access_token == @board
    end
  end

  def get_board
    if !(user_signed_in?) || current_user.is_admin?
      @board = Board.friendly.find(params[:id])
    else
      @board = @project.boards.friendly.find(params[:id])
    end
  end

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end
end
