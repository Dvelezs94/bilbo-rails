namespace :remove_webp_images do
  desc "Remove all webp images"
  task :delete_all => :environment do
    ActiveStorage::Attachment.where(id: [ActiveStorage::Blob.where(content_type: "image/webp").pluck(:id)]).destroy_all
    p "Se han removido todas las imagenes webp"
  end
end
