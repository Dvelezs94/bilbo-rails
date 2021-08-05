class DashboardPlayer < ApplicationRecord
  belongs_to :project
  has_many :board_dashboard_players, class_name: "BoardDashboardPlayer"
  has_many :boards, through: :board_dashboard_player
  attr_accessor :board_slug
  after_create :create_board_player
  after_update :create_board_player

  def create_board_player
     #self.board_players.where(board_id: Board.friendly.find(board_slug).id).first_or_create
  end
end
