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

      all.each do |item|
        csv << attributes.map{ |attr| item.send(attr) }
      end
    end
    return "#{tmp_dir}/#{name}"
  end

end
