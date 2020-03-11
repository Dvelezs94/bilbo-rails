class ProviderImpressionsCsvWorker
    include Sidekiq::Worker
    sidekiq_options retry: false, dead: false

  
    def perform(user_id)
      @user = User.find(user_id)
      name = "impressions-#{Time.now.strftime("%Y%m%d")}"
      generate_csv 
      send_csv
    end

private

    def generate_csv 
      attributes = %w["campaign", "board", "created_at", "total_price", "name" ]
      require 'csv'
        CSV.open("tmp/report.csv") do |csv|
          csv << attributes 
          Report.create.attachment
        end
      end
      def send_csv(csv)
        send_data csv, :type => 'text/csv; charset=utf-8; header=present', :disposition => 'attachment; filename=impressions.csv'
    end

end
  