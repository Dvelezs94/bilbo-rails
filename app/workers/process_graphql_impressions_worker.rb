class ProcessGraphqlImpressionsWorker
    include Sidekiq::Worker
    sidekiq_options retry: 2, backtrace: 10
  
    def perform(mutation_id, api_token, board_slug, campaign_id, cycles, created_at)
        begin
             Impression.create!(
                board: Board.friendly.find(board_slug),
                uuid: mutation_id,
                campaign_id: campaign_id,
                cycles: cycles,
                duration: Campaign.find(campaign_id).true_duration(board_slug),
                created_at: created_at,
                api_token: api_token
            )
        rescue ActiveRecord::RecordNotUnique => e
            if !Rails.env.test? && !Rails.env.development?
                Bugsnag.notify("record not unique for impression with hour #{created_at} on board #{board_slug}")
            else
                puts "====record not unique for impression with hour #{created_at}"
            end
        end
    end
end
  