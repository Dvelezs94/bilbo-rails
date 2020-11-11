namespace :fill_cycle_price_for_bc do
  desc "Fill the cycle_price field of all boards_campaigns"

  task :do_it => :environment do |t|
    BoardsCampaigns.all.includes(:board).each do |bc|
      bc.update(cycle_price: bc.board.cycle_price) unless bc.cycle_price.present?
    end
    p "All BoardsCampaigns have been updated"
  end
end
