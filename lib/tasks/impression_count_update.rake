namespace :impression_count_update do
  desc "This job update the field of impression count in every campaigns"
  #bilbo run rails impression_count_update:do_it
  task :do_it => :environment do
    Campaign.all.find_in_batches(batch_size: 50) do |group|
      @msg = []
      group.map { |campaign|
        campaign.with_lock do
          campaign.assign_attributes(impression_count: campaign.impressions.size)
          campaign.save(:validate => false) if campaign.impression_count_changed?
        end
        @msg.append("campaña: #{campaign.name} impresiones: #{campaign.impression_count}/")
      }
      @msg.each do |msg|
        p msg.split("/")
      end
    end
    p "Impresiones actualizadas"
  end
end
