class BoardsController < ApplicationController
  include AwsFunctionsHelper
  access [:provider, :admin, :user, :all] => [:index], [:user, :provider] => [:owned, :statistics], provider: [ :regenerate_access_token, :regenerate_api_token], all: [:show, :map_frame, :get_info, :requestAdsRotation, :index], admin: [:toggle_status, :admin_index, :create, :edit, :update, :delete_image, :delete_default_image, :reload_board]
  # before_action :get_all_boards, only: :show
  before_action :get_board, only: [:statistics, :requestAdsRotation, :show, :regenerate_access_token, :regenerate_api_token, :toggle_status, :update, :delete_image, :delete_default_image, :reload_board, :validate_default_contents_size]
  before_action :update_boardscampaigns, only: [:requestAdsRotation, :show]
  before_action :restrict_access, only: [:show]
  before_action :validate_identity, only: [:regenerate_access_token, :regenerate_api_token]
  before_action :validate_just_api_token, only: [:requestAdsRotation]
  before_action :validate_default_contents_size, only: [:create, :update]
  before_action :allow_iframe_requests, only: :map_frame

  def index
    respond_to do |format|
    format.js { #means filter is used
      # get all boards within that range and start filtering after
      get_boards(lat: params[:lat], lng: params[:lng], radius: params[:radius])
      if params[:cycle_price].present?
        @boards = @boards.select{ |board| board.cycle_price <= params[:cycle_price].to_f }
        @boards = Board.where(id: @boards)
      end
      @boards = @boards.where("height > ?", params[:min_height]) if params[:min_height].present?
      @boards = @boards.where("width > ?", params[:min_width]) if params[:min_width].present?
      @boards = @boards.where(category: params[:category]) if params[:category].present?
      @boards = @boards.where(smart: true) if params[:smart] == "1"
      @boards = @boards.where(social_class: params[:social_class]) if params[:social_class].present?
     }
    format.html {
      get_boards
     }
   end
  end

  def edit
    @board = Board.friendly.find(params[:id])
    @content = @board.board_default_contents.map{|bdc| bdc.content}
  end

  def delete_image
    @board.with_lock do
      image = @board.images.select { |im| im.signed_id == params[:signed_id] }[0]
      image.purge
    end
  end

  def delete_default_image
    if @board.board_default_contents.size > 1
      if @board.board_default_contents.find(params[:default_id]).delete
        @success_message = I18n.t("board_default_content.update_success")
      else
        @error_message = I18n.t("error.error_ocurred")
      end
      if  @board.connected?
        UpdateBoardDefaultContentWorker.perform_async(@board.id, "delete_default_content", params[:content_id])
      end
    else
      @error_message = I18n.t("board_default_content.minimum_one")
    end
  end

  def requestAdsRotation
    @board.with_lock do
      if @board.should_update_ads_rotation?
        errors = @board.update_ads_rotation
        if errors.any?
          if !Rails.env.development?
            Bugsnag.notify("Un error impidió actualizar el ads_rotation en el bilbo #{@board.slug}:\n#{errors.first}")
          else
            p "Un error impidió actualizar el ads_rotation en el bilbo #{@board.slug}:\n#{errors.first}"
          end
          return head(:internal_server_error)
        end
        ActionCable.server.broadcast(
          @board.slug,
          action: "update_rotation",
          ads_rotation: @board.add_bilbo_campaigns.to_s
        )
      end
    end
  end

  def update
    @success = @board.update(board_params.merge(admin_edit: true))
    if params[:content].present?
      params[:content].map { |file|
        cont = @board.project.contents.new(multimedia: file )
        if cont.save
          @board.board_default_contents.where(content_id: cont.id).first_or_create
        end
      }
    end

    if board_params[:url].present?
        cont = @board.project.contents.new(url: board_params[:url] )
        if cont.save
          @board.board_default_contents.where(content_id: cont.id).first_or_create
        end
    end

    if @board.connected? && (board_params[:url].present? || params[:content].present? )
      UpdateBoardDefaultContentWorker.perform_async(@board.id, "update_default_content")
    end
    #check if needs to deactivate campaigns when updates from admin form
    if @success
      active_provider_campaigns = @board.active_campaigns("provider").sort_by { |c| (c.classification == "per_hour")? 0 : 1}
      deactivated = 0
      @board.update_ads_rotation(true) if active_provider_campaigns.empty? #update also if its empty to resize space if needed
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
    get_boards(lat: params[:lat], lng: params[:lng], radius: params[:radius])
  end

  # provider boards
  def owned
    @boards = @project.boards.search(params[:search_board]).order(created_at: :desc).page(params[:page])
  end

  def show
    errors = @board.update_ads_rotation if @board.should_update_ads_rotation?
    @active_campaigns = @board.active_campaigns
    # Set api key cookie
    cookies.signed[:api_key] = {
      value: @board.api_token,
      path: request.env['PATH_INFO']
    }
  end


  def create
    if board_params[:upload_from_csv].present?
      csvfile = board_params[:upload_from_csv]
      s3_url = upload_to_s3(csvfile.path, "files/CSV_#{Time.now.strftime("%Y%m%d%H%M%S")}.csv") if !Rails.env.development?
      if s3_url.present?
        BoardUploadWorker.perform_async(s3_url, board_params[:project_id])
        flash[:success] = "Creating boards, you will receive a notification once the worker finishes processing all the boards"
      elsif !Rails.env.development?
        flash[:error] = "There was an error when uploading the csv file to s3"
      else
        #Manage the file locally for development
        file_path = Rails.root.join("storage/CSV_#{Time.zone.now.strftime("%Y%m%d%H%M%S")}.csv")
        FileUtils.mv(csvfile.path, file_path)
        BoardUploadWorker.perform_async(file_path, board_params[:project_id])
        flash[:success] = "Creating boards, you will receive a notification once the worker finishes processing all the boards"
      end
      redirect_to root_path
    else
      @board = Board.new(board_params)
      if @board.save
        if params[:content].present?
          params[:content].map { |file|
            cont = @board.project.contents.new(multimedia: file )
            if cont.save
              @board.board_default_contents.where(content_id: cont.id).first_or_create
            end
          }
          if board_params[:url].present?
            cont = @board.project.contents.new(url: board_params[:url] )
            if cont.save
              @board.board_default_contents.where(content_id: cont.id).first_or_create
            end
          end
        end
        flash[:success] = "Board saved"
      else
        flash[:error] = "Could not save board"
      end
      redirect_to root_path
    end
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
    @bilbo_top = Board.provider_top_campaigns(@board, 3.months.ago..Time.now, 2).first(4)
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

  def reload_board
    if @board.connected?
      ActionCable.server.broadcast(
      @board.slug, action: "reload")
      @success_message = I18n.t("bilbos.reload_success")
    else
      @error_message = I18n.t("bilbos.reload_off")
    end
  end

  private

  def board_params
    params.require(:board).permit(:project_id,
                                  :name,
                                  :upload_from_csv,
                                  :avg_daily_views,
                                  :width,
                                  :height,
                                  :lat,
                                  :lng,
                                  :radius,
                                  :address,
                                  :category,
                                  :start_time,
                                  :end_time,
                                  :face,
                                  :base_earnings,
                                  :social_class,
                                  :utc_offset,
                                  :duration,
                                  :minimum_budget,
                                  :images_only,
                                  :extra_percentage_earnings,
                                  :mac_address,
                                  :keep_old_cycle_price_on_active_campaigns,
                                  :displays_number,
                                  :provider_earnings,
                                  :restrictions,
                                  :content,
                                  :url,
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

  # default location to center of mexico
  # search radius is defaulted to 10km
  def get_boards(lat: 19.4324451, lng: -99.1333817, radius: 10000)
    if user_signed_in? && @project.provider?
      @boards = @project.boards.enabled.within_radius(lat, lng, radius.to_i)
    else
      @boards = Board.enabled.within_radius(lat, lng, radius.to_i)
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

  def update_boardscampaigns
    BoardsCampaigns.includes(:campaign).where(board: @board, status: "approved").each do |bc|
      bc.update(update_remaining_impressions: true) if !bc.campaign.per_minute? #Update the remaining impressions of all campaigns of the board except campaigns per minute
    end
  end

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end

  def validate_default_contents_size
    if !board_params[:upload_from_csv].present?
      if params[:content].present?
        if params[:url].present?
          content_size = params[:content].size + 1
        else
          content_size = params[:content].size
        end
      elsif  params[:url].present?
        content_size = 1
      else
        content_size = 0
      end
      
      if @board.present?
        content_size = content_size + @board.board_default_contents.size
      end

      if !(content_size < 10)
        flash[:alert] =  I18n.t("board_default_content.maximum_ten")
        redirect_to request.referer
      elsif (content_size == 0)
        flash[:alert] =  I18n.t("board_default_content.minimum_one")
        redirect_to request.referer
      end
    end
  end
end
