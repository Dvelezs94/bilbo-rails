module Types
  class ImpressionType < Types::BaseObject
    field :id, ID, null: true
    field :board, Types::BoardType, null: false
    field :campaign, Types::CampaignType, null: true
    field :total_price, Float, null: true
    field :cycles, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
