class AdsController < ApplicationController
  def create
    @ad = Ad.new(ad_params)
    if @ad.save
      flash[:success] = "Ad saved"
    else
      flash[:error] = "Could not save ad"
    end
    redirect_back(fallback_location: root_path)
  end
  private
  def ad_params
    params.require(:ad).permit(:name, multimedia: []).merge(:user_id => current_user.id)
  end
end
