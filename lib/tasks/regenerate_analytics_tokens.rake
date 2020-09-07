namespace :regenerate_analytics_tokens do
  desc "Generate analytics tokens for all campaigns"
  task :do_it => :environment do
    Campaign.where(analytics_token: nil).each do |campaign|
      @token = SecureRandom.hex(4).first(7)
      campaign.update_attribute(:analytics_token, @token)
      p "campaña #{campaign.name} ha actualizado su token a #{@token}"
    end
    p "Se han aztualizado todas los tokens de las campañas"
  end
end
