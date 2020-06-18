module UserActivityHelper
  def track_activity(user: current_user, action:, activeness:)
    UserActivity.create(user: user, activeness: activeness, activity: action)
  end
end
