module Bilbo
  class API < Grape::API
    version 'v1'
    format :json
    prefix :api

    resource :boards do
      desc 'Return a list of all external boards'
      get :board_time do
        board_offset = Board.friendly.find(params[:slug]).utc_offset
        return {:board_time => ((Time.now.utc + board_offset.minutes).strftime("%H:%M") rescue "")}
      end
    end
  end
end
