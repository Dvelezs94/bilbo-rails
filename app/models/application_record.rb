class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # export records to csv
  # You can pass the fields you want to include on the csv, example
  # current_user.boards.to_csv(attributes = ["id", "base_earnings", "status"])
  def self.to_csv(attributes = ["id"])
    require 'csv'
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |item|
        csv << attributes.map{ |attr| item.send(attr) }
      end
    end
  end
end
