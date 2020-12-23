namespace :set_available_campaigns do
  desc "Give access to all type of campaigns to projects owned by a provider"

  task :do_it => :environment do |t|
    Project.where(classification: "provider").update(available_campaign_types: ["budget","per_minute","per_hour"].to_s)
  end
end
