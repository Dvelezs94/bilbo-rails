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

    def sync_all
      user_group_id = 107759053
      provider_group_id = 107759071


      users = User.where(roles: "user")
      providers = User.where(roles: "provider")

      users_subscribers = []
      providers_subscribers = []

      for user in users
        users_subscribers.push({ email: user.email, name: user.name_or_none })
      end

      for provider in providers
        providers_subscribers.push({ email: provider.email, name: provider.name_or_none })
      end

      # Call methods to create subscribers
      MailerLite.import_group_subscribers(user_group_id, users_subscribers, resubscribe: false)
      MailerLite.import_group_subscribers(provider_group_id, providers_subscribers, resubscribe: false)
    end
  end
  