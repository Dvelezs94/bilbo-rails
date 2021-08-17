class DashboardPlayer < ApplicationRecord
  belongs_to :project
  has_many :board_dashboard_players, class_name: "BoardDashboardPlayer"
  has_many :boards, through: :board_dashboard_player
  attr_accessor :board_slug
end
