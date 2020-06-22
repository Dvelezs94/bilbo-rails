class ProviderImpressionsCsvWorker
    include Sidekiq::Worker
    include NotificationsHelper
    include Rails.application.routes.url_helpers
    sidekiq_options retry: false, dead: false


    def perform(project_slug, user_id)
      @project = Project.friendly.find(project_slug)
      @impressions = @project.daily_provider_board_impressions(10.years.ago..Time.now)
      name = "impressions-#{Time.now}.csv"
      result = @impressions.to_csv(name, ["campaign", "board", "created_at", "total_price"])
      @report = @project.reports.create!(name: name)
      @report.attachment.attach(io: File.open(result), filename: name, content_type: ',	text/csv')
      puts report_url
      create_notification(recipient_id: @project.id, actor_id: @project.id , action: "csv ready", notifiable: User.find(user_id))
    end

    def report_url
      rails_blob_url(@report.attachment)
    end
end
