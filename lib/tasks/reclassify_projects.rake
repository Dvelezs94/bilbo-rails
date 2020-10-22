namespace :reclassify_projects do
  desc "assign proper classification to projects depending on the owner role"
  task :do_it => :environment do
    Project.all.each do |pr|
      pr.update(classification: pr.owner.role.to_s)
      p "Project #{pr.name} updated to #{pr.classification}"
    end
    p "Se han actualizado todos los proyectos"
  end
end
