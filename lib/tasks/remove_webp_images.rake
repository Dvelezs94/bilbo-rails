namespace :remove_webp_images do
  desc "Remove all webp images"
  task :delete_all => :environment do
    ids = ActiveStorage::Blob.where(content_type: "image/webp").pluck(:id)
    p "id de imagenes webp: #{ids}"
    ActiveStorage::Attachment.where(id: [ids]).each do |bl|
      p "Destroying blob with ID: #{bl.id}"
      begin
        bl.destroy!
      rescue => e
        p "could not destroy blob with ID: #{bl.id}, error: #{e}"
      end
    end
    p "Se han removido todas las imagenes webp"
  end
end
