namespace :update_ads_rotation do
  desc "updates all board ads rotation"
  task :do_it => :environment do
    Board.all.each(&:update_ads_rotation)
    p "Se han actualizado todos los ads rotation"
  end

end
