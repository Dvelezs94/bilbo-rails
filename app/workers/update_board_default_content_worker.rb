class UpdateBoardDefaultContentWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false
  include Rails.application.routes.url_helpers

  def perform(board_id, action)
    board = Board.find(board_id)
    board.with_lock do
      content = board.board_default_contents.map{|contents| contents.content}
      if board.images_only
        append_msg = ApplicationController.renderer.render(partial: "board_default_contents/board_default_content", collection: content.select{|c| c.multimedia.content_type.include? "image"}, as: :media, locals: {board: board})
      else
        append_msg = ApplicationController.renderer.render(partial: "board_default_contents/board_default_content", collection: content, as: :media, locals: {board: board})
      end

      # build html to append
      broadcast_to_boards(board.slug, action, append_msg)
    end
  end

  private
  def broadcast_to_boards(channel, action, ad)
    p "x" * 800
    ActionCable.server.broadcast(
      channel,
      action: action,
      ad: ad
    )
  end
end
