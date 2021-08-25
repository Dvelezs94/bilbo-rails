class ExternalSourcesController < ApplicationController
    before_action :verify_cookies, only: :setup

    def setup
      cookies.permanent.signed[:enableServiceWorker] = params[:enableServiceWorker] if params[:enableServiceWorker].present?
    end

    def configure
      # make sure the board exists and have mac_address before setting the cookies
      if Board.find_by(slug: params[:board_slug], access_token: params[:board_token]).present? && Board.find_by(slug: params[:board_slug], access_token: params[:board_token]).mac_address.present?
        if params[:mac_address].present? && Board.find_by(slug: params[:board_slug], access_token: params[:board_token], mac_address: params[:mac_address].downcase).present?
            cookies.permanent.signed[:board_slug] = params[:board_slug]
            cookies.permanent.signed[:board_token] = params[:board_token]
            cookies.permanent.signed[:mac_address] = params[:mac_address]
            redirect_to_board
        else
          flash[:error] = "Error al introducir los datos, intentalo nuevamente."
          redirect_to setup_external_sources_path
        end
        # make sure the board exists before setting the cookies
      elsif Board.find_by(slug: params[:board_slug], access_token: params[:board_token]).present? && Board.find_by(slug: params[:board_slug], access_token: params[:board_token]).mac_address.to_s.empty?
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
      if cookies.signed[:board_slug] && cookies.signed[:board_token] && cookies.signed[:mac_address]
        if Board.find_by(slug: cookies.signed[:board_slug], access_token: cookies.signed[:board_token], mac_address: cookies.signed[:mac_address].downcase).present?
          redirect_to_board
        end
      elsif cookies.signed[:board_slug] && cookies.signed[:board_token]
        # even if the cookies are set, we need to make sure the board exists with those parameters
        if Board.find_by(slug: cookies.signed[:board_slug], access_token: cookies.signed[:board_token]).present?
          redirect_to_board
        end
      end
    end

    def redirect_to_board
      if cookies.signed[:mac_address]
        redirect_to board_path(cookies.signed[:board_slug], access_token: cookies.signed[:board_token], mac_address: cookies.signed[:mac_address])
      else
        redirect_to board_path(cookies.signed[:board_slug], access_token: cookies.signed[:board_token])
      end
   end
end
