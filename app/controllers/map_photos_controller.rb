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
        format.js {render "map_photos/create_multimedia.js.erb", :locals => {:single_image => [@photo], :message => @success_message, format: "image"}, status: :created }
      end
    end
  end
end
