class Mutations::CreateImpression < Mutations::BaseMutation
  argument :api_token, String, required: true
  argument :board_id, Integer, required: true
  argument :campaign_id, Integer, required: true
  argument :cycles, Integer, required: true
  argument :created_at, GraphQL::Types::ISO8601DateTime, required: true

  field :impression, Types::ImpressionType, null: false
  field :errors, [String], null: false

  def resolve(api_token:, board_id:, campaign_id:, cycles:, created_at:)
    impression = Impression.new(
      board_id: board_id,
      campaign_id: campaign_id,
      cycles: cycles,
      created_at: created_at,
      api_token: api_token)

    if impression.save
      {
        impression: impression,
        errors: []
      }
    else
      raise GraphQL::ExecutionError, impression.errors.full_messages.join(", ")
    end
  end
end
