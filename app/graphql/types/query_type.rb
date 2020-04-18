module Types
  class QueryType < Types::BaseObject
    # This works, just commented it out to avoid hacks
    # field :boards, [Types::BoardType], null: true
    #
    # def boards
    #   Board.all
    # end
    #
    # field :board, Types::BoardType, null: false do
    #   argument :slug, String, required: true
    # end
    #
    # def board(slug:)
    #   Board.friendly.find(slug)
    # end
    #
    # field :campaigns, [Types::CampaignType], null: true
    #
    # def campaigns
    #   Campaign.all
    # end
    #
    # field :campaign, Types::CampaignType, null: false do
    #   argument :slug, String, required: true
    # end
    #
    # def campaign(slug:)
    #   Campaign.friendly.find(slug)
    # end
    #
    # field :impression, Types::ImpressionType, null: false do
    #   argument :id, ID, required: true
    # end
    # def impression(id:)
    #   Impression.find(id)
    # end
  end
end
