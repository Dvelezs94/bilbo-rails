class SessionsController < Devise::SessionsController
  before_action :require_project!, only: [:new]
end
