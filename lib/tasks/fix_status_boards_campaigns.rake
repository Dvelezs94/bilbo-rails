namespace :update_status_boards_campaigns do
  desc "updates all status of boards campaigns correctly"
  task :do_it => :environment do
    BoardsCampaigns.where(status: 1).update(status: 0)
    BoardsCampaigns.where(status: 2).update(status: 1)
    BoardsCampaigns.where(status: 3).update(status: 2)
    p "All status had been updated"
  end

end
