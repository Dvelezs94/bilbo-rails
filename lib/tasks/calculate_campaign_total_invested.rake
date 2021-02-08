namespace :calculate_campaign_total_invested do
  desc "Sets total_invested value to all campaigns"
  task :run => :environment do
    Campaign.all.each do |camp|
      begin
        camp.with_lock do
          camp.update_column(:total_invested, Impression.where(campaign_id: camp.id).sum(:total_price))
        end
      rescue
        "Error al actualizar la campaña #{camp.name}"
      end
      p "Se han actualizado las inversiones totales de la campaña #{camp.name}."
    end
    p "Tarea finalizada."
  end
end
