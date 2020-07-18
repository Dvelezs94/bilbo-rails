class ExternalSourcesController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :verify_cookies, only: :setup

    def setup
    end

    def configure
        # make sure the board exists before setting the cookies
        if Board.find_by(slug: params[:board_slug], access_token: params[:board_token]).present?
            cookies.permanent.signed[:board_slug] = params[:board_slug]
            cookies.permanent.signed[:board_token] = params[:board_token]
            redirect_to_board
        else
            flash[:error] = "Error al introducir los datos, intentalo nuevamente."
            redirect_to setup_external_sources_path
        end
    end

    private
    # if the cookies exist, then redirect to board
    def verify_cookies
        if cookies.signed[:board_slug] && cookies.signed[:board_token]
            # even if the cookies are set, we need to make sure the board exists with those parameters
            if Board.find_by(slug: cookies.signed[:board_slug], access_token: cookies.signed[:board_token]).present?
                redirect_to_board
            end
        end
    end

    def redirect_to_board
        redirect_to board_path(cookies.signed[:board_slug], access_token: cookies.signed[:board_token])
    end
end