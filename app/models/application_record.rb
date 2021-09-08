class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.destroy_duplicates_by(*columns)
    groups = select(columns).group(columns).having(Arel.star.count.gt(1))
    groups.each do |duplicates|
      records = where(duplicates.attributes.symbolize_keys.slice(*columns))
      records.offset(1).destroy_all
    end
  end

  # export records to csv
  # You can pass the fields you want to include on the csv, example
  # current_user.boards.to_csv(attributes = ["id", "base_earnings", "status"])
  # csv << [data1, data2]
  def self.to_csv(name, attributes = ["id"])
    require 'csv'
    tmp_dir = "tmp/multimedia"
    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
    CSV.open("#{tmp_dir}/#{name}", "w") do |csv|
      csv << attributes
      attributes.pop() #pop attribute created_at
      time_zone_board={} #json that saves each time zone
      all.each do |item|
        #condition to save time zone once per board
        if !time_zone_board["#{item.board.id}"]
          time_zone_board["#{item.board.id}"] = Timezone.lookup(item.board.lat, item.board.lng).to_s #find timezone with lat and lng and save timezone on time_zone_board
        end
        data_array = attributes.map{ |attr| item.send(attr)} #data selected on attributes [campaign, board, total_price]
        data_array.push(item.created_at.in_time_zone(time_zone_board["#{item.board.id}"])) #in_time_zone change the time zone on created_at
        csv << data_array #puts data in the csv
      end
    end
    return "#{tmp_dir}/#{name}"
  end

end
