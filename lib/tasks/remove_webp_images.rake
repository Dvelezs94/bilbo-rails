namespace :remove_webp_images do
  desc "Remove all webp images"
  task :delete_all => :environment do
    ids = ActiveStorage::Blob.where(content_type: "image/webp").pluck(:id)
    puts ids
    ActiveStorage::Attachment.where(id: [ids]).each do |bl|
      "Destroying blob with ID: #{bl.id}"
      begin
        bl.destroy!
      rescue
        "could not destroy blob with ID: #{bl.id}"
      end
    end
    p "Se han removido todas las imagenes webp"
  end
end
