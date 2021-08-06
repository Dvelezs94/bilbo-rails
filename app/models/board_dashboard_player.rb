class BoardDashboardPlayer < ApplicationRecord
  belongs_to :board
  belongs_to :dashboard_player
end
