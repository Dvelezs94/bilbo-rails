namespace :delete_duplicated_impressions do
  desc "deletes duplicated impressions"
  task :do_it => :environment do
    Impression.destroy_duplicates_by(:created_at, :board_id)
    p "finished deleting duplicated impressions"
  end
end
