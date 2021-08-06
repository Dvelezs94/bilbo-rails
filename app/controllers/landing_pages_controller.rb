# Not used right now but it will be in future tickets
class LandingPagesController < ApplicationController
    before_action :get_board
    def show_board
    end

    private

    def get_board 
        @board = Board.friendly.find(params[:id])
    end
end