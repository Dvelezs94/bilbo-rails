namespace :remove_bots do
  desc "Remove all bot users"
  task :delete_all => :environment do
    User.where("name LIKE ?", "%http%").destroy_all
    p "Se han removido todos los bots"
  end
end
