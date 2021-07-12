class BoardDefaultContentsController < ApplicationController
  access [:provider] => :all
  before_action :verify_identity

  def create_or_update_default_content
    begin
      @board = Board.friendly.find(params[:board_slug])
      contents = Content.where(id: params[:selected_contents].split(" "))
      if contents.length != 0
        if contents.length <= 10
          contents.each do |content|
            @board_default_content = @board.board_default_contents.where(content_id: content.id).first_or_create
          end
          @board.board_default_contents.where.not(content_id: contents).each do |bdc|
            if @board.connected?
              UpdateBoardDefaultContentWorker.perform_async(@board.id, "delete_default_content", bdc.content_id)
            end
            bdc.delete
          end
            if @board.connected?
              UpdateBoardDefaultContentWorker.perform_async(@board.id, "update_default_content")
            end
            @success_message = I18n.t("board_default_content.update_success")
          else
            @error_message = I18n.t("board_default_content.maximum_ten")
          end
      else
        @error_message = I18n.t("board_default_content.minimum_one")
      end
    rescue
        @error_message = I18n.t("error.error_ocurred")
    end
  end

  def edit_default_content
    #Return the content for modal step 2
    @board = Board.friendly.find(params[:board_slug])
  end

  def contents_board_modal
    @board = Board.friendly.find(params[:board_slug])
    @slug = params[:board_slug]
    contents = []
    if @board.images_only
      @project.contents.order(id: :desc).each do |content|
        if !content.is_video?
          contents.push(content)
        end
      end
    else
      @project.contents.order(id: :desc).map{|content|contents.push(content)}
    end
    @content = Kaminari.paginate_array(contents.uniq).page(params[:upcoming_page]).per(15)
    #@content = Kaminari.paginate_array(@project.contents).page(params[:upcoming_page]).per(15)
  end

  def get_selected_default_contents
    @board = Board.friendly.find(params[:board_slug])
    @selected_contents = Content.where(id: params[:selected_contents].split(" "))
  end

  def fetch_single_wizard_content
    @content = Content.find(params[:id])
  end

  private
  def verify_identity
    raise_not_found if not @project.users.pluck(:id).include? current_user.id
  end
end
