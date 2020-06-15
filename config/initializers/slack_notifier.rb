SLACK_NOTIFIER = Slack::Notifier.new ENV.fetch("SLACK_WEBHOOK_URL") {""} do
  defaults channel: "#support",
           username: "bilbo-app",
           icon_emoji: ":robot_face:"
end
