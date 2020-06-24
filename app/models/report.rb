class Report < ApplicationRecord
  belongs_to :project
  belongs_to :campaign, optional: :true
  belongs_to :board, optional: :true
  has_one_attached :attachment

    def last_report_created
      if self.present?
        if self.last.updated_at < Time.zone.now - 24.hours
          @report.save
        end
      end
    end
end
