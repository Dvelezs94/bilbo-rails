# Load rake tasks
require 'rake'
Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
Bilbo::Application.load_tasks

class BoardUploadWorker
  include Sidekiq::Worker
  include AwsFunctionsHelper
  include ShrineContentHelper
  sidekiq_options retry: false

  def perform(file, project_id)
    files = {} #Store all the files in this hash to avoid downloading a single file multiple times
    successful = 0 #Count the successful uploads
    @errors = []
    CSV.new((Rails.env.development?? File.open(file) : open(file)), :headers => true).each_with_index do |row, index|
      item = {}
      item[:project_id] = project_id

      item[:name] = [row["TIPO"], row["Nombre"]].filter{|a| a.present?}.map{|a| a.strip}.join(' ')
      item[:name] = nil if item[:name] == "" #Do not allow empty string as a name, set it to nil to raise an error

      error1 = []
      # Google Maps info to get lat and lon
      unformatted_addr = [row["DOMICILIO"], row["COLONIA"], row["CP"], row["MUNICIPIO"], row["ESTADO"]].filter{|a| a.present?}.join(', ')
      location = Geokit::Geocoders::GoogleGeocoder.geocode(unformatted_addr)
      begin
        item[:address] = location.formatted_address
        item[:lat] = row["LATITUD"] || location.lat
        item[:lng] = row["LONGITUD"] || location.lng
        item[:utc_offset] = Timezone.lookup(item[:lat], item[:lng]).utc_offset / 60
      rescue
        error1.append("No se pudo localizar la direccion en el mapa") if item[:address].nil?
        error1.append("No se pudo encontrar la latitud del bilbo") if item[:lat].nil?
        error1.append("No se pudo encontrar la longitud del bilbo") if item[:lng].nil?
        error1.append("No se pudo encontrar la zona horaria del bilbo") if item[:utc_offset].nil?
      end
      # Ensure the category is valid, if it's not then leave it as nil to raise an error later
      screen_type = (row["Tipo de Medio"] || "").downcase.strip
      if screen_type.in? ["espectacular", "billboard"]
        item[:category] = "billboard"
      elsif screen_type.in? ["televisión","television"]
        item[:category] = "television"
      elsif screen_type.in? ["cartelon","cartelón","wallboard", "Mupi", "mupi"]
        item[:category] = "wallboard"
      end

      item[:minimum_budget] = [ (row["Mínimo de compra"].strip.remove("$").remove(',') || 0).to_f , 50].max

      item[:avg_daily_views] = row["Trafico Mensual"].to_i / 30
      item[:displays_number] = row["Numero de pantallas"].to_i || 1

      # Compute the base earnings based on the impression cost and the working time of the board
      item[:start_time] = row["Hora de inicio"]
      item[:end_time] = row["Hora Fin"]
      working_minutes = (Time.zone.parse(item[:end_time]) - Time.zone.parse(item[:start_time]))/1.minutes % 1440
      working_minutes = 1440 if working_minutes == 0

      if row["Ganancias proveedor"].present? || row["Precio proveedor"].present?
        item[:provider_earnings] = row["Ganancias proveedor"].present?? row["Ganancias proveedor"].to_f : row["Precio proveedor"].strip.remove('$').remove(',').to_f * (working_minutes * 6 * 10.0/row["Duracion de anuncio (s)"].to_i) * 30
      else
        error1.append("No fue posible calcular el precio del bilbo (precio de proveedor)")
      end

      if row["Ganancias bilbo"].present? || row["Precio Bilbo"].present?
        item[:base_earnings] = row["Ganancias bilbo"].present?? row["Ganancias bilbo"].to_f : row["Precio Bilbo"].strip.remove('$').remove(',').to_f * (working_minutes * 6 * 10.0/row["Duracion de anuncio (s)"].to_i) * 30
      else
        error1.append("No fue posible calcular el precio del bilbo (precio de lista)")
      end

      item[:smart] = row["SMART"].downcase.in? ["yes","si", "sí", "s", "y"]

      #Set default face to interior in case it is not provided in the file
      item[:face] = row["Cara"].downcase.strip || "interior"

      item[:social_class] = row["Categoria"]

      item[:width] = row["Anchura (m)"].to_f
      item[:height] = row["Altura (m)"].to_f

      item[:duration] = row["Duracion de anuncio (s)"].to_i

      item[:restrictions] = split_restrictions(row["Restricciones"] || "").to_json

      item[:images_only] = !(["mp4","video"].map{|format| row["Formato"].downcase.include? format}.any?) #Set images only to true if video or mp4 is not present in format column
      if row["Steps"].present?
        item[:steps] = true
        if row["Spots mínimos por día"].present? && !row["Multiplos"].present?
          @prices = []
          base_earnings = item[:base_earnings]
          daily_seconds = working_minutes * 60
          duration = item[:duration]
          cycle_price = (base_earnings / (daily_seconds * 30)) * duration
          minimum_budget = item[:minimum_budget]
          index = 0
          loop do
            index = index + 1
            price = (minimum_budget * (index)).to_i
            minimum_budget/cycle_price > row["Spots mínimos por día"].to_i
            break if  minimum_budget/cycle_price > row["Spots mínimos por día"].to_i
            @prices.push([price])
          end
          if @prices.present?
            item[:multiplier] = @prices.size
          else
            item[:multiplier] = 1
          end
        elsif row["Multiplos"].present?
          item[:multiplier] = row["Multiplos"].to_i
        end
      end

      # Ensure that the board has a name and category before doing anything else
      error1.append("El nombre del bilbo no puede estar vacio") if item[:name].nil?
      error1.append("El tipo de medio no es valido o esta vacio") if item[:category].nil?
      if error1.present?
        error1.prepend("No se pudo guardar el board")
        @errors.append([(item[:name] || "(Sin nombre)") + " (fila #{index+2})", error1])
        next
      end

      #Save and handle errors
      @board = Board.new(item) #Create the board with the info collected above
      success = @board.save
      ####################################################################################

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
                brd_errors.append("El enlace #{url} no contiene un archivo multimedia valido (se encontro #{image.content_type})")
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
                brd_errors.append("El enlace '#{url}' no contiene un archivo multimedia valido (se encontro #{image.content_type})")
                next
              end
            rescue
              brd_errors.append("No se pudo obtener el contenido del enlace '#{url}'")
              next
            end
          end
          content = image_data(image, image.content_type, File.basename(url))
          content_created = @board.project.contents.create(multimedia_data: content)
            cont = BoardDefaultContent.new
            cont.board_id = @board.id
            cont.content_id = content_created.id
            cont.save
        end
      else #attach the default bilbo image
        if files.keys.include? 'https://s3.amazonaws.com/cdn.bilbo.mx/Frame+25.png'
          image = files['https://s3.amazonaws.com/cdn.bilbo.mx/Frame+25.png']
          image.rewind
        else
          image = open('https://s3.amazonaws.com/cdn.bilbo.mx/Frame+25.png')
          files['https://s3.amazonaws.com/cdn.bilbo.mx/Frame+25.png'] = image
        end
        content = image_data(image, image.content_type, File.basename(url))
        content_created = @board.project.contents.create(multimedia_data: content)
          cont = BoardDefaultContent.new
          cont.board_id = @board.id
          cont.content_id = content_created.id
          cont.save
      end

      brd_errors.append("Los formatos admitidos son: image/jpeg, image/png, image/jpg, y video/mp4") if brd_errors.present?

      #Notify if the board doesn't have images even if it was saved
      brd_errors += @board.errors.full_messages
      brd_errors.append("Aviso: No se encontraron o no se pudieron guardar las imagenes del bilbo") if @board.images.count == 0
      brd_errors.append("Aviso: No se encontraron o no se pudieron guardar las imagenes default del bilbo") if @board.board_default_contents.count == 0
      if !success
        brd_errors.prepend("No se pudo guardar el board")
      end
      if brd_errors.present?
        @errors.append([(@board.name || "(Sin nombre)") + " (fila #{index+2})", brd_errors])
      else
        successful += 1
      end

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
    # p @errors
    if @errors.empty?
      SlackNotifyWorker.perform_async("#{successful} nuevos bilbos fueron creados correctamente, no se encontraron errores")
    else
      report_tempfile = Tempfile.new("report.txt")
      File.open(report_tempfile.path,'w+') do |report|
        @errors.each do |title, values|
          report.write(title+":"+"\n")
          values.each do |message|
            report.write("\t"+message+"\n")
          end
          report.write("\n")
        end
      end
      s3_report_url = upload_to_s3(report_tempfile.path, "reports/#{Time.now.strftime("%Y%m%d%H%M%S")}.txt") if !Rails.env.development?

      if s3_report_url.present?
        SlackNotifyWorker.perform_async("#{successful} nuevos bilbos fueron creados correctamente, se encontraron errores, descarga el reporte en el siguiente enlace:\n#{s3_report_url}: ")
      else
        #If its there is any error when uploading the report to s3, make sure that we can check it on the server storage
        report_path = "storage/#{Time.now.strftime("%Y%m%d%H%M%S")}.txt"
        FileUtils.mv(report_tempfile.path, report_path)
        ObjectSpace.undefine_finalizer(report_tempfile)
        SlackNotifyWorker.perform_async("#{successful} nuevos bilbos fueron creados correctamente\nNo fue posible subir el reporte a s3, revisa el reporte en la ruta: #{report_path}")
      end
    end
    # Get board metadata fields for landing pages
    Rake::Task['set_boards_address_metadata:set'].invoke if !Rails.env.development?
  end

  def split_restrictions(concat_restricctions)
    #Remove content in parenthesis
    concat_restricctions = concat_restricctions.gsub /\((.*?)\)/, ''

    #Separate items by commas
    return concat_restricctions.split(',').map{|s| s.strip}
  end
end
