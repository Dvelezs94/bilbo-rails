class ProviderImpressionsCsvWorker
    include Sidekiq::Worker
    include Rails.application.routes.url_helpers
    include NotificationsHelper
    sidekiq_options retry: false, dead: false

    #optional parameters for the type of csv
    def perform(project_slug, user_id, campaign_id = nil, board_id= nil, start_date= nil, end_date= nil)
      @project = Project.friendly.find(project_slug)
      name = "impressions-#{Time.zone.now}.csv"
        if campaign_id.present?
          if board_id.present?
            #if campaign, board and dates are present, create a csv for impressions of board and campaign selected in time range
            if start_date.present?
              @impressions = @project.boards.find(board_id).impressions.where(campaign: campaign_id).where("created_at >= ? AND created_at <= ?", start_date, end_date)
              @report = @project.reports.create!(name: name, category: "board_campaign", campaign_id: campaign_id, board_id: board_id)
            end
          else
          #if only campaign is present, create a csv with the campaign selected
            @impressions = @project.campaigns.find(campaign_id).impressions
            @report = @project.reports.create!(name: name, category: "campaign", campaign_id: campaign_id)
          end
          #if board present and date isn't there create a csv of board
          elsif board_id.present? && !start_date.present?
            @impressions = @project.boards.find(board_id).impressions
            @report = @project.reports.create!(name: name, category: "board", board_id: board_id)
        else
          #if only is the proyect, csv of all impressions of provider
          @impressions = @project.daily_provider_board_impressions(10.years.ago..Time.zone.now)
          @report = @project.reports.create!(name: name, category: "project")
        end
      if @project.provider?
        @report_fields = ["campaign", "board", "created_at", "provider_price"]
      else
        @report_fields = ["campaign", "board", "created_at", "total_price"]
      end
      result = @impressions.to_csv(name, @report_fields)
      file_csv = File.open(result)
      @report.attachment.attach(io: file_csv, filename: name, content_type: 'text/csv')
      puts report_url
      File.delete(result)
      #create a notification for download a csv
      create_notification(recipient_id: @project.id, actor_id: @project.id , action: "csv ready", notifiable: User.find(user_id), reference: @project.reports.find_by_name(name))
    end

    def report_url
      rails_blob_url(@report.attachment)
    end
end
