namespace :delete_duplicated_impressions do
  desc "deletes duplicated impressions"
  task :do_it => :environment do
    i = Impression.all.group_by { |i|  [i.created_at, i.board_id] } #makes groups of impression that have same both creation and board id
    i.each {|key, arr| arr.each_with_index do |imp, ind|
        if ind != 0
        imp.destroy
        p "impression deleted ##{ind} for the campaign #{imp.campaign_id} on the board #{imp.board_id}"
      end
     end
    }
    p "finished deleting duplicated impressions"
  end
end
