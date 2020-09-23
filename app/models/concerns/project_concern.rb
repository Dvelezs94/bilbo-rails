module ProjectConcern
  # make sure the project is enabled before doing any action
  def project_enabled?
    if !self.project.enabled?
      errors.add(:base, "Project is disabled")
    end
  end
end
