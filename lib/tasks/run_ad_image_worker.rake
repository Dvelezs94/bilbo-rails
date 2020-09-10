namespace :run_ad_image_worker do
  desc "Runs image converter worker for all ads"
  task :do_it => :environment do
    Ad.all.each do |ad|
      ImageResizeWorker.perform_async(ad.id)
      p "agendado el ad #{ad.id} para el worker"
    end
    p "Se han agendado todos los ads para optimizarse"
  end

end
