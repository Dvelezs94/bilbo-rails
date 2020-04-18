module Types
  class MutationType < Types::BaseObject
    field :create_impression, mutation: Mutations::CreateImpression
  end
end
