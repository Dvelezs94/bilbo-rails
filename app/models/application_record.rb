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
  def self.to_csv(name, attributes = ["id"])
    require 'csv'
    tmp_dir = "tmp/multimedia"
    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
    CSV.open("#{tmp_dir}/#{name}", "w") do |csv|
      csv << attributes
      attributes.pop()
      time_zone_board={}
      all.each do |item|
        if !time_zone_board["#{item.board.id}"]
          time_zone_board["#{item.board.id}"] = Timezone.lookup(item.board.lat, item.board.lng).to_s
        end
        array = attributes.map{ |attr| item.send(attr)}
        array.push(item.created_at.in_time_zone(time_zone_board["#{item.board.id}"]))
        csv << array
      end
    end
    return "#{tmp_dir}/#{name}"
  end

end
