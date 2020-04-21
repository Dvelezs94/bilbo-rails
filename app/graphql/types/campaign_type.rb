module Types
  class CampaignType < Types::BaseObject
    field :id, ID, null: false
    field :slug, String, null: false
    field :name, String, null: false
    field :budget, Float, null: false
    field :status, String, null: false
    field :state, String, null:false
    field :starts_at, GraphQL::Types::ISO8601DateTime, null: true
    field :ends_at, GraphQL::Types::ISO8601DateTime, null: true
    field :impressions, [Types::ImpressionType], null: true
  end

  def state
    object.state? ? "enabled" : "disabled"
  end
end
