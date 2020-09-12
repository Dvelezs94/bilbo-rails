class ShortenersController < ApplicationController
  before_action :get_shortener

  def show
    redirect_to @shortener.target_url
  end

  private
  def get_shortener
    @shortener = Shortener.find_by_token(params[:id])
  end
end
