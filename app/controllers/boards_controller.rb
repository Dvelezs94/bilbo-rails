class BoardsController < ApplicationController
  access [:provider, :admin, :user] => [:index], [:user, :provider] => [:owned, :statistics, :index], provider: [ :regenerate_access_token, :regenerate_api_token], all: [:show, :map_frame, :get_info, :requestAdsRotation], admin: [:toggle_status, :admin_index, :create, :edit, :update, :delete_image, :delete_default_image, :reload_board]
  # before_action :get_all_boards, only: :show
  before_action :get_board, only: [:statistics, :requestAdsRotation, :show, :regenerate_access_token, :regenerate_api_token, :toggle_status, :update, :delete_image, :delete_default_image, :reload_board]
  before_action :update_boardscampaigns, only: [:requestAdsRotation, :show]
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
          ads_rotation: @board.add_bilbo_campaigns.to_s
        )
      end
    end
  end

  def update
    @success = @board.update(board_params.merge(admin_edit: true))
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
    get_boards
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
      @errors = []
      create_boards_from_csv(csvfile.path, board_params[:project_id])
      if @errors.present?
        render "admin/boards/errors"
      else
        flash[:success] = "All boards succesfully created"
        redirect_to root_path
      end
    else
      @board = Board.new(board_params)
      if @board.save
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
                                  :user_email,
                                  :upload_from_csv,
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
                                  :restrictions,
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

  def update_boardscampaigns
    BoardsCampaigns.includes(:campaign).where(board: @board, status: "approved").each do |bc|
      bc.update(update_remaining_impressions: true) if !bc.campaign.per_minute? #Update the remaining impressions of all campaigns of the board except campaigns per minute
    end
  end

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end

  def create_boards_from_csv(file, project_id)
    files = {} #Store all the files in this hash to avoid downloading a single file multiple times
    CSV.foreach(file, :headers => true).each_with_index do |row, index|
      item = {}
      item[:project_id] = project_id

      item[:name] = [row["TIPO"], row["Nombre"]].filter{|a| a.present?}.join(' ')
      item[:name] = nil if item[:name] == "" #Do not allow empty string as a name, set it to nil to raise an error

      # Google Maps info to get lat and lon
      unformatted_addr = [row["DOMICILIO"], row["COLONIA"], row["CP"], row["MUNICIPIO"], row["ESTADO"]].filter{|a| a.present?}.join(', ')
      location = Geokit::Geocoders::GoogleGeocoder.geocode(unformatted_addr)
      item[:address] = location.formatted_address
      item[:lat] = row["LATITUD"] || location.lat
      item[:lng] = row["LONGITUD"] || location.lng
      item[:utc_offset] = Timezone.lookup(location.lat, location.lng).utc_offset / 60

      # Ensure the category is valid, if it's not then leave it as nil to raise an error later
      screen_type = (row["Tipo de Medio"] || "").downcase.strip
      if screen_type.in? ["espectacular", "billboard"]
        item[:category] = "billboard"
      elsif screen_type.in? ["televisión","television"]
        item[:category] = "television"
      elsif screen_type.in? ["cartelon","cartelón","wallboard"]
        item[:category] = "wallboard"
      end

      item[:avg_daily_views] = row["Trafico Mensual"].to_i / 30
      item[:displays_number] = row["Numero de pantallas"].to_i || 1

      # Compute the base earnings based on the impression cost and the working time of the board
      item[:start_time] = row["Hora de inicio"]
      item[:end_time] = row["Hora Fin"]
      working_minutes = (Time.zone.parse(item[:end_time]) - Time.zone.parse(item[:start_time]))/1.minutes % 1440
      working_minutes = 1440 if working_minutes == 0
      item[:base_earnings] = row["Ganancias por mes"].present?? row["Ganancias por mes"].to_f : row["Precio por Spot"].to_f * (working_minutes * 6 * 10.0/row["Duracion de anuncio (s)"].to_i) * 30
      item[:extra_percentage_earnings] = row["Porcentaje extra esperado"].strip.remove('%') || 20  #Remove % symbol if its present and store only the value

      #Set default face to North in case it is not present
      face = row["Cara"].downcase.strip
      if face.in? ["sur", "south"]
        item[:face] = "south"
      elsif face.in? ["este", "east"]
        item[:face] = "east"
      elsif face.in? ["oeste", "west"]
        item[:face] = "west"
      elsif face.in? ["cuarto 1"]
        item[:face] = "cuarto 1"
      else
        item[:face] = "north"
      end

      item[:social_class] = row["Categoria"]

      item[:width] = row["Anchura (m)"].to_f
      item[:height] = row["Altura (m)"].to_f

      item[:duration] = row["Duracion de anuncio (s)"].to_i

      item[:restrictions] = split_restrictions(row["Restricciones"] || "").to_json

      item[:images_only] = !(["mp4","video"].map{|format| row["Formato"].downcase.include? format}.any?) #Set images only to true if video or mp4 is not present in format column

      @board = Board.new(item) #Create the board with the info collected above

      #Handle specific errors (ensure that the board has a name and category before doing anything else)
      error1.append(["El nombre del bilbo no puede estar vacío"]) if @board.name.nil?
      error1.append(["El tipo de medio no es válido o está vacío"]) if @board.category.nil?
      if @board.name.nil? || @board.category.nil?
        error1.prepend("No se pudo guardar el board")
        @errors.append([(@board.name || "(Sin nombre)") + " (fila #{index+1})", error1])
        next
      end

      #Save and handle errors
      success = @board.save

      brd_errors = []
      if row["Imagenes"].present?  #Load images from urls if they are provided
        row["Imagenes"].split().each_with_index do |url, index|
          if files.keys.include? url
            image = files[url]
            image.rewind
          else
            begin #Make sure that the content can be retrieved
              image = open(url)
              if image.content_type.in? ["image/jpg","image/jpeg","image/png","video/mp4"]
                files[url] = image
              else
                brd_errors.append("El enlace #{url} no contiene un archivo multimedia válido (se encontró #{image.content_type})")
                next
              end
            rescue
              brd_errors.append("No se pudo obtener el contenido del enlace '#{url}'")
              next
            end
          end
          @board.images.attach(io: image, filename: File.basename(url), content_type: image.content_type)
        end
      end
      if row["Imagenes default"].present? #Load default images from urls if they are provided, else set the default bilbo image
        row["Imagenes default"].split().each_with_index do |url, index|
          if files.keys.include? url
            image = files[url]
            image.rewind
          else
            begin #Make sure that the content can be retrieved
              image = open(url)
              if image.content_type.in? ["image/jpg","image/jpeg","image/png","video/mp4"]
                files[url] = image
              else
                brd_errors.append("El enlace '#{url}' no contiene un archivo multimedia válido (se encontró #{image.content_type})")
                next
              end
            rescue
              brd_errors.append("No se pudo obtener el contenido del enlace '#{url}'")
              next
            end
          end
          @board.default_images.attach(io: image, filename: @board.name.split().join('-') + '.' + image.content_type.split('/')[1], content_type: image.content_type)
        end
      else #attach the default bilbo image
        if files.keys.include? 'https://s3.amazonaws.com/cdn.bilbo.mx/Frame+25.png'
          image = files['https://s3.amazonaws.com/cdn.bilbo.mx/Frame+25.png']
          image.rewind
        else
          image = open('https://s3.amazonaws.com/cdn.bilbo.mx/Frame+25.png')
          files['https://s3.amazonaws.com/cdn.bilbo.mx/Frame+25.png'] = image
        end
        @board.default_images.attach(io: image, filename: "bilbo-default.png", content_type: image.content_type)
      end

      brd_errors.append("Los formatos admitidos son: image/jpeg, image/png, image/jpg, y video/mp4") if brd_errors.present?

      #Notify if the board doesn't have images even if it was saved
      brd_errors += @board.errors.full_messages
      brd_errors.append("Aviso: No se encontraron o no se pudieron guardar las imagenes del bilbo") if @board.images.count == 0
      brd_errors.append("Aviso: No se encontraron o no se pudieron guardar las imagenes default del bilbo") if @board.default_images.count == 0
      if !success
        brd_errors.prepend("No se pudo guardar el board")
      end
      @errors.append([(@board.name || "(Sin nombre)") + " (fila #{index+1})", brd_errors]) if brd_errors.present?
    end

    # Close and delete created temp files
    files.values.each do |file|
      # When the file size is lower than 10kb, the system can use it as a StringIO object, without storing any file
      # If the file size is larger, then it creates a Tempfile that should be deleted after using it
      if file.is_a? Tempfile
        file.close
        file.unlink
      end
    end
  end

  def split_restrictions(concat_restricctions)
    #Remove content in parenthesis
    concat_restricctions = concat_restricctions.gsub /\((.*?)\)/, ''

    #Separate items by commas
    return concat_restricctions.split(',').map{|s| s.strip}
  end
end
