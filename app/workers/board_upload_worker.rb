class BoardUploadWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(file_path, project_id)
    files = {} #Store all the files in this hash to avoid downloading a single file multiple times
    successful = 0 #Count the successful uploads
    @errors = []
    CSV.foreach(file_path, :headers => true).each_with_index do |row, index|
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
      elsif screen_type.in? ["cartelon","cartelón","wallboard"]
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


      # Ensure that the board has a name and category before doing anything else
      error1.append("El nombre del bilbo no puede estar vacío") if item[:name].nil?
      error1.append("El tipo de medio no es válido o está vacío") if item[:category].nil?
      if error1.present?
        error1.prepend("No se pudo guardar el board")
        @errors.append([(item[:name] || "(Sin nombre)") + " (fila #{index+1})", error1])
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
          @board.default_images.attach(io: image, filename: File.basename(url), content_type: image.content_type)
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
      if brd_errors.present?
        @errors.append([(@board.name || "(Sin nombre)") + " (fila #{index+1})", brd_errors])
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
      report_url = Rails.root.join("storage/board_upload_report_#{Time.zone.now.strftime("%Y%m%d%H%M%S")}.txt")
      File.open(report_url,'w+') do |report|
        @errors.each do |title, values|
          report.write(title+":"+"\n")
          values.each do |message|
            report.write("\t"+message+"\n")
          end
          report.write("\n")
        end
      end

      SlackNotifyWorker.perform_async("#{successful} nuevos bilbos fueron creados correctamente, se encontraron errores, revisa el reporte en la siguiente ruta: #{report_url.to_s}: ")
    end
  end

  def split_restrictions(concat_restricctions)
    #Remove content in parenthesis
    concat_restricctions = concat_restricctions.gsub /\((.*?)\)/, ''

    #Separate items by commas
    return concat_restricctions.split(',').map{|s| s.strip}
  end
end
