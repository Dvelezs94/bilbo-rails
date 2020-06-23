class ProviderImpressionsCsvWorker
    include Sidekiq::Worker
    include NotificationsHelper
    include Rails.application.routes.url_helpers
    sidekiq_options retry: false, dead: false


    def perform(project_slug, user_id, campaign_id = nil, board_id= nil, start_date= nil, end_date= nil)
      @project = Project.friendly.find(project_slug)
        if campaign_id.present?
          if board_id.present?
            if start_date.present?
              @impressions = @project.boards.find(board_id).impressions.where(campaign: campaign_id).where("created_at >= ? AND created_at <= ?", start_date, end_date)
            end
        else
            @impressions = @project.campaigns.find(campaign_id).impressions
          end
        elsif board_id.present? && !start_date.present?
          @impressions = @project.boards.find(board_id).impressions
        else
          @impressions = @project.daily_provider_board_impressions(10.years.ago..Time.zone.now)
        end
      name = "impressions-#{Time.zone.now}.csv"
      result = @impressions.to_csv(name, ["campaign", "board", "created_at", "total_price"])
      @report = @project.reports.create!(name: name)
      @report.attachment.attach(io: File.open(result), filename: name, content_type: 'text/csv')
      puts report_url
      create_notification(recipient_id: user_id, actor_id: @project.id , action: "csv ready", notifiable: User.find(user_id), reference: @project.reports.find_by_name(name))
    end

    def report_url
      rails_blob_url(@report.attachment)
    end
end
