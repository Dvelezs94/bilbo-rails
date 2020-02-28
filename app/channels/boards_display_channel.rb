class BoardsDisplayChannel < ApplicationCable::Channel

  def subscribed
    # Condition for check if there are any connection
    if !Redis.new(url: ENV.fetch("REDIS_URL_ACTIONCABLE")).pubsub("channels", params[:id])[0].present?
      # Channel utilized to send messages to all boards
      stream_from "shared_channel"
      # Board channel
      stream_from params[:id]
    else
      # Reject the subscription
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end

  def reject
    # Change the state of the subscription
    @reject_subscription = true
  end

end
