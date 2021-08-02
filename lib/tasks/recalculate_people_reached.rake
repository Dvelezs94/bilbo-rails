namespace :recalculate_people_reached do
  desc "Reacalculate people reached for all campaigns"
  task :run => :environment do
    Campaign.includes(:boards).where(created_at: 2.months.ago.beginning_of_day .. Time.now).each do |campaign|
      begin
        total_reach = 0.0
        campaign.impressions.group_by(&:board_id).map{|k,v| [k, v.length, v.first.duration]}.each do |board_id, count, duration|
          total_reach += (Board.find(board_id).people_per_second * duration) * count
        end
        campaign.update_columns(people_reached: total_reach)
        p "Se ha actualizado la campaña #{campaign.name} a #{campaign.people_reached}"
      rescue
        p "Error al actualizar campaña #{campaign.name}"
      end
    end

    p "Se han actualizado todas las campañas"
  end
end
