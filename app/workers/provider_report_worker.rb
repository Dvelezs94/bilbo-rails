class ProviderReportWorker
    include Sidekiq::Worker
    sidekiq_options retry: false, dead: false

  
    def perform(user_id)
      @impressions = User.find(user_id).daily_provider_board_impressions(10.years.ago..Time.now)
      @impressions.to_csv(["campaign", "board", "created_at", "total_price"]), filename: "impressions-#{Date.today}.csv" 
    end
end
  