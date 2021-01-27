namespace :impression_count_update do
  desc "This update the count of impressions of campaigns"
  #bilbo run rails impression_count_update:do_it
  task :do_it => :environment do
    Campaign.all.each do |campaign|
      campaign.with_lock do
        campaign.assign_attributes(impression_count: Impression.where(campaign_id: campaign).count)
        campaign.save(:validate => false)
        p "campaña: #{campaign.name} impresiones: #{campaign.impression_count}"
      end
    end
    p "Impresiones actualizadas"
  end
end
