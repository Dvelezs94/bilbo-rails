class ProviderImpressionsCsvWorker
    include Sidekiq::Worker
    sidekiq_options retry: false, dead: false

  
    def perform(user_id)
      @user = User.find(user_id)
      generate_csv 
    end

private

    def generate_csv 
      attributes = %w["campaign", "board", "created_at", "total_price" ]
      require 'csv'
        CSV.generate(headers: true) do |csv|
          csv << attributes 
        end
      end
    

end
  