class Mutations::CreateImpression < Mutations::BaseMutation
  argument :api_token, String, required: true
  argument :mutationid, ID, required: true
  argument :board_slug, String, required: true
  argument :campaign_id, ID, required: true
  argument :cycles, Integer, required: true
  argument :created_at, String, required: true

  field :impression, Types::ImpressionType, null: false
  field :action, String, null: false
  field :mutationid, String, null: false
  field :errors, [String], null: false


  def resolve(api_token:, board_slug:, campaign_id:, cycles:, created_at:, mutationid:)
    begin
      mutation_short = mutationid.first(15)
      ProcessGraphqlImpressionsWorker.perform_async(mutation_short, api_token, board_slug, campaign_id.to_i, cycles, created_at)
      # once processed, delete the impression on the player js
      imp_action = "delete"
    rescue => e
      Bugsnag.notify(e)
      # keep the impression since there was an error queuing the impression
      imp_action = "keep"
    end
    res = {
      mutationid: mutationid,
      action: imp_action
    }
    return res
  end
end
