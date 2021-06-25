# using Mailerlite's Ruby Library
# https://github.com/jpalumickas/mailerlite-ruby/blob/master/examples/subscribers.md
module MailerliteHelper
    def sync_mailerlite_user(user)
      if Rails.env.production?
        if user.is_provider?
          group_id = "107759071"
        else
          group_id = "107759053"
        end

        subscriber = { email: user.email, name: user.name_or_none }
        result = MailerLite.create_group_subscriber(group_id, subscriber)
        return result
      end
    end
  end
  