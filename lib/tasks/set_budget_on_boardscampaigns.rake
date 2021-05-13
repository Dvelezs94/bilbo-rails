namespace :set_budget_on_boardscampaigns do
  desc "Distribute the budget of all existing campaings on their respective BoardsCampaigns"
  task :do_it => :environment do
    Campaign.includes(:board_campaigns).where(classification: "budget").each do |c|
      next if c.budget.nil?
      budget_per_bilbo = c.budget / c.board_campaigns.count
      c.board_campaigns.update(budget: budget_per_bilbo)
    end
    p "El presupuesto de cada campaña se ha distribuido equitativamente entre sus board_campaigns correspondientes"
  end
end
