class BoardMapPhotosController < ApplicationController
  access :admin => :all

  def edit_board_images
    @board = Board.friendly.find(params[:board_slug])
  end

  def images_board_modal
    @board = Board.friendly.find(params[:board_slug])
    @slug = params[:board_slug]
    photos = []
    MapPhoto.joins(:board_map_photos).where(board_map_photos: {board_id: @board.project.boards.pluck(:id)}).map{|photo| photos.push(photo)}
    @photos = Kaminari.paginate_array(photos.uniq).page(params[:upcoming_page]).per(15)
  end

  def get_selected_map_photos
    @board = Board.friendly.find(params[:board_slug])
    @selected_photos = MapPhoto.where(id: params[:selected_photos].split(" "))
  end

end
