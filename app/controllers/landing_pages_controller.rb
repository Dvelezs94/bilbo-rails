# Not used right now but it will be in future tickets
class LandingPagesController < ApplicationController
    before_action :get_board

    def show
        # If no board is found, then return a not found
        if !@board.present?
            raise_not_found
        end
        @suggested_boards = Board.by_distance(origin: [@board.lat, @board.lng]).enabled.where.not(id: @board.id).where(smart: true).first(10).shuffle.take(4)
    end

    private

    def get_board
        @board = Board.enabled.where(country_state: params[:state], city: params[:city], parameterized_name: params[:name]).first
    end
end