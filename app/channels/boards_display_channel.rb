class BoardsDisplayChannel < ApplicationCable::Channel
  def subscribed
    # Channel utilized to send messages to all boards
    stream_from "shared_channel"

    # Board channel
    stream_from params[:id]

  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
