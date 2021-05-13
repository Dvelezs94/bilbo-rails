class ProcessGraphqlImpressionsWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0, backtrace: 10
  
    def perform(api_token, board_slug, campaign_id, cycles, created_at)
        begin
             Impression.create!(
                board: Board.friendly.find(board_slug),
                campaign_id: campaign_id,
                cycles: cycles,
                duration: Campaign.find(campaign_id).true_duration(board_slug),
                created_at: created_at,
                api_token: api_token
            )
        rescue ActiveRecord::RecordNotUnique => e
            if !Rails.env.test? && !Rails.env.development?
                Bugsnag.notify("record not unique for impression with hour #{created_at}")
            else
                puts "====record not unique for impression with hour #{created_at}"
            end
        rescue => e
            if !Rails.env.test? && !Rails.env.development?
                SlackNotifyWorker.perform_async("Error al crear impresion para el board #{board_slug}. \n #{e}")
            else
                #puts "Error al crear impresion para el board #{board_slug}. \n #{e}"
                puts "An error of type #{e.class} happened, message is #{e.message}"
            end
        end
    end
end
  