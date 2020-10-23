namespace :reclassify_projects do
  desc "assign proper classification to projects depending on the owner role"
  task :do_it => :environment do
    Project.enabled.each do |pr|
      begin
        pr.update(classification: pr.owner.role.to_s)
        p "Project #{pr.name} updated to #{pr.classification}"
      rescue
        p "Error updating project #{pr.name}"
      end
    end
    p "Se han actualizado todos los proyectos"
  end
end
