namespace :remove_webp_images do
  desc "Remove all webp images"
  task :delete_all => :environment do
    ids = ActiveStorage::Blob.where(content_type: "image/webp").pluck(:id)
    puts ids
    ActiveStorage::Attachment.where(id: [ids]).each do |bl|
      puts "Destroying blob with ID: #{bl.id}"
      begin
        bl.destroy!
      rescue => e
        puts "could not destroy blob with ID: #{bl.id}, error: #{e}"
      end
    end
    p "Se han removido todas las imagenes webp"
  end
end
