class MapPhotosController < ApplicationController
  access :admin => :all

  def new_image
    @image = MapPhoto.new
    if params[:photos_modal].present?
      render 'new_multimedia'
    end
  end

  def create_multimedia
    @photo = MapPhoto.create(image: params[:multimedia])
    respond_to do |format|
      if !@photo.save
        format.js {render js: @photo.errors.full_messages.first, status: 500}
      else
        @success_message = t("content.success")
        format.js {render :template => "map_photos/create_multimedia.js.erb"}
      end
    end
  end
end
