class Report < ApplicationRecord
  belongs_to :project
  has_one_attached :attachment

    def last_report_created
      if self.present?
        if self.last.updated_at < Time.now - 24.hours
          @report.save
        end  
      end 
    end
end
