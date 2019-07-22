class BoardsController < ApplicationController
  before_action :authenticate_user!
  # before_action :get_all_boards, only: :show

  def show
  end

  private
  def get_all_boards
    @boards = Board.enabled.pluck(:id, :latitude, :longitude).to_json
  end
end
