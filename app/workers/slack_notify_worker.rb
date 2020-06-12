class SlackNotifyWorker
    include Sidekiq::Worker
    sidekiq_options retry: false, dead: false

    # simple job that sends a slack notification. Useful because slack can hang sometimes
    def perform(message)
      SLACK_NOTIFIER.ping message
    end
end
