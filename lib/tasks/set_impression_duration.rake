namespace :set_impression_duration do
  desc "Sets duration to all impressions"
  task :run => :environment do
    Campaign.all.each do |camp|
      begin
        duration = camp.duration
      rescue
        duration = 10
      end
      camp.impressions.update_all(duration: duration)
      p "Se ha actualizado la duración de las impresiones de la campaña #{camp.name}."
    end
    p "Tarea finalizada."
  end
end
