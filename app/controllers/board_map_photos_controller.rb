class BoardMapPhotosController < ApplicationController
  access :admin => :all

  def edit_board_images
    @board = Board.friendly.find(params[:board_slug])
  end

  def images_new_board_modal
    photos = []
    project = User.find_by_email(params[:user_email]).projects.first
    newly_created = JSON.parse(params[:uploaded_photos])
    MapPhoto.joins(:board_map_photos).where(board_map_photos: {board_id: project.board_ids}).map{|photo| photos.push(photo)}
    MapPhoto.where(id: newly_created).map{|photo| photos.push(photo)} if newly_created.present?
    @photos = Kaminari.paginate_array(photos.uniq).page(params[:upcoming_page]).per(15)
  end

  def images_board_modal
    @board = Board.friendly.find(params[:board_slug])
    @slug = params[:board_slug]
    photos = []
    MapPhoto.joins(:board_map_photos).where(board_map_photos: {board_id: @board.project.boards.pluck(:id)}).map{|photo| photos.push(photo)}
    @currently_used_photos = @board.board_map_photos.map{|p| p.map_photo_id}
    @photos = Kaminari.paginate_array(photos.uniq).page(params[:upcoming_page]).per(15)
  end

  def get_selected_map_photos
    @board = Board.friendly.find(params[:board_slug]) if params[:board_slug].present?
    parsed_ids = JSON.parse(params[:selected_photos]).map{|x| x.to_i}
    @selected_photos = MapPhoto.where(id: parsed_ids)
  end

  def create_or_update_board_map_photos
    #selected_photos (JSON Array)
    #board_slug
    begin
      board_id = Board.friendly.find(params[:board_slug]).id
      photos = MapPhoto.where(id: JSON.parse(params[:selected_photos]))
      photos.each do |photo|
        _photo = BoardMapPhoto.where(board_id: board_id, map_photo_id: photo.id).first_or_create
      end
      BoardMapPhoto.where(board_id: board_id).where.not(map_photo_id: photos).each do |bmp|
        bmp.destroy
      end
      @success_message = I18n.t('board_default_content.update_success')
    rescue
      @error_message = I18n.t('error.error_ocurred')
    end

  end

  def fetch_single_map_photo
    @photo = MapPhoto.find(params[:id])
  end

end
