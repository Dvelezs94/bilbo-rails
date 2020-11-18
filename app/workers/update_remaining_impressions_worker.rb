class UpdateRemainingImpressionsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform
    BoardsCampaigns.includes(:campaign).all.update(update_remaining_impressions: true)
    # Campaign.where(clasification: "budget").each do |cpn|
    #   cpn.boards.each do |b|
    #     imp = (cpn.budget_per_bilbo/b.get_cycle_price(cpn)).to_i
    #     bc = BoardsCampaigns.find_by(campaign: cpn, board: b)
    #     if bc.remaining_impressions != imp
    #       bc.update(update_remaining_impressions: true)
    #     end
    #   end
    # end
    p "All user remaining impressions have been reseted"
  end
end
