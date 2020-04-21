module Types
  class BoardType < Types::BaseObject
    field :id, ID, null: false
    field :slug, String, null: false
    field :name, String, null: false
    field :lat, Float, null: false
    field :lng, Float, null: false
    field :width, Float, null: false
    field :height, Float, null: false
    field :status, String, null: false
    field :address, String, null: false
    field :face, String, null: false
    field :campaigns, [Types::CampaignType], null: true
  end
end
