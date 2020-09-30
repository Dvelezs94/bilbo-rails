namespace :update_processed_ad do
  desc "Change the state processed from false to true for attachments in the ad"
  task :do_it => :environment do
    puts "start"
    Ad.all.each do |ad|
      ad.multimedia.attachments.each do |attach|
        attach.update(processed:true)
        puts "..."
      end
    end
    puts "finish"
  end
end
