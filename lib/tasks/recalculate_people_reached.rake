namespace :recalculate_people_reached do
  desc "Reacalculate people reached for all campaigns"
  task :run => :environment do
    Campaign.all.each do |campaign|
      begin
        campaign.update_columns(people_reached: 0)
        campaign.impressions.each do |imp|
          imp.update_people_reached
        end
        p "Se ha actualizado la campaña #{campaign.name} a #{campaign.people_reached}"
      rescue
        p "Error al actualizar campaña #{campaign.name}"
      end
    end

    p "Se han actualizado todas las campañas"
  end
end
