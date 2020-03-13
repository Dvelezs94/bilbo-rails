class ProviderImpressionsCsvWorker
    include Sidekiq::Worker
    include Rails.application.routes.url_helpers
    sidekiq_options retry: false, dead: false

  
    def perform(user_id)
      @user = User.find(user_id)
      @impressions = @user.daily_provider_board_impressions(10.years.ago..Time.now)
      name = "impressions-#{Time.now}.csv"
      result = @impressions.to_csv(name, ["campaign", "board", "created_at", "total_price"])
      @report = Report.create!(name: name, user: @user)
      @report.attachment.attach(io: File.open(result), filename: name, content_type: ',	text/csv')  
      puts report_url
    end

    def report_url
      rails_blob_path(@report.attachment, disposition: "attachment", only_path: true)
    end
end
