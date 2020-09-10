namespace :update_hour_campaign_format do
  desc "Change the format of the hour campaigns in the db to the nested form format"
  task :do_it => :environment do
    cpn = Campaign.where(clasification: "per_hour").where.not(hour_start: nil, hour_finish: nil, imp: nil)
    cpn.each do |c|
      start_t = c.hour_start
      end_t = c.hour_finish
      impressions = c.imp
      ImpressionHour.create(start: start_t, end: end_t, imp: impresions, campaign_id: c.id, day: "everyday")
      p "Campaign with id #{c.id} was updated"
    end
    p "All hour campaigns have been updated"
  end
end
