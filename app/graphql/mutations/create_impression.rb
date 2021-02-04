class Mutations::CreateImpression < Mutations::BaseMutation
  argument :api_token, String, required: true
  argument :mutationid, String, required: true
  argument :board_slug, String, required: true
  argument :campaign_id, String, required: true
  argument :cycles, Integer, required: true
  argument :created_at, GraphQL::Types::ISO8601DateTime, required: true

  field :impression, Types::ImpressionType, null: false
  field :action, String, null: false
  field :mutationid, String, null: false
  field :errors, [String], null: false


  def resolve(api_token:, board_slug:, campaign_id:, cycles:, created_at:, mutationid:)
    impression = Impression.new(
      board: Board.friendly.find(board_slug),
      campaign_id: campaign_id.to_i,
      cycles: cycles,
      duration: Campaign.includes(:ad).find(campaign_id).true_duration(board_slug),
      created_at: created_at,
      api_token: api_token
    )

    begin
      success = impression.save
    rescue => e
      Bugsnag.notify(e)
    end
    ##### CURRENTLY THE OBJECT IMPRESSION HAS NO USE IN STREAMING MANAGER #####
      {
        impression: impression,
        mutationid: mutationid,
        action: impression.action,
        errors: [impression.errors.full_messages.join(", ")]
      }

  end
end
