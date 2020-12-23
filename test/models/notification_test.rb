require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  setup do
      @name = "Provider"
      @project =  create(:project, name: @name)
      @user = create(:user,name: @name , email: "#{name}@bilbo.mx".downcase, roles: "provider")
      @campaign = create(:campaign, name: "notif", project: @user.projects.first, project_id: @project.id, state: false, provider_campaign: @user.is_provider?)
      @board = create(:board,project: @user.projects.first, name: "Pedro", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    end

    test 'notification exists' do
      @notification = create(:notification, recipient_id: @project.id, actor_id: @project.id, action: "out of credits", notifiable: @user, reference: nil, sms: false)
      assert_equal 1, @project.notifications.count
    end

    test 'notification has recipient' do
      @notification = create(:notification, recipient_id: @project.id, actor_id: @project.id, action: "out of credits", notifiable: @user, reference: nil, sms: false)
      assert_equal @notification.recipient_id, @project.notifications.first.recipient_id
    end


    test 'notification campaign created' do
      @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 0)
      @notification = create(:notification, recipient_id: @project.id, actor_id: @campaign.project.id, action: "created", notifiable: @campaign, reference: @board)
      assert_equal "created", @project.notifications.first.action
    end

    test 'notification campaign approved' do
      @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
      @notification = create(:notification, recipient_id: @project.id, actor_id: @campaign.project.id, action: "approved", notifiable: @campaign, reference: @board)
      assert_equal "approved", @project.notifications.first.action
    end

    test 'notification campaign denied' do
      @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 2)
      @notification = create(:notification, recipient_id: @campaign.project.id, actor_id: @board.project.id, action: "denied", notifiable: @campaign, reference: @board)
      assert_equal "denied", @project.notifications.first.action
    end

    test 'notification campaign time campaign error' do
      @notification = create(:notification, recipient_id: @project.id, actor_id: @project.id , action: "time campaign error", notifiable: @campaign)
      assert_equal "time campaign error", @project.notifications.first.action
    end

    test 'notification csv' do
      @report = create(:report, name: @name, project: @project)
      @notification = create(:notification, recipient_id: @project.id, actor_id: @project.id , action: "csv ready", notifiable: @user, reference: @project.reports.first)
      assert_equal "csv ready", @project.notifications.first.action
    end

    test 'notification invite project' do
      @name_user_one = "Joaquin"
      @name_user_two = "Raul"
      @project_for_user =  create(:project, name: @name_user_one)
      @user_two = create(:user,name: @name_user_two , email: "#{@name_user_two}@bilbo.mx".downcase)
      @user_one = create(:user,name: @name_user_one , email: "#{@name_user_one}@bilbo.mx".downcase)
      @project_user = create(:project_user, role: @user_two.role, email: @user_two.email , project_id: @project_for_user.id)
      @notification = create(:notification, recipient_id: @project_for_user.id, actor_id: @project_for_user.id, action: "new invite", notifiable: @project_for_user, reference: @user_two )
      assert_equal "new invite", @user_two.notifications.first.action
    end

    test 'notification out of credits' do
      @name_user_one = "Joaquin"
      @user_one = create(:user,name: @name_user_one , email: "#{@name_user_one}@bilbo.mx".downcase)
      @notification = create(:notification, recipient_id: @project.id, actor_id: @project.id, action: "out of credits", notifiable: @user_one)
      assert_equal "out of credits", @project.notifications.first.action
    end

    test 'notification remove project' do
      @name_user_one = "Joaquin"
      @name_user_two = "Raul"
      @project_for_user =  create(:project, name: @name_user_one)
      @user_one = create(:user,name: @name_user_one , email: "#{@name_user_one}@bilbo.mx".downcase)
      @user_two = create(:user,name: @name_user_two , email: "#{@name_user_two}@bilbo.mx".downcase)
      @notification = create(:notification, recipient_id: @project_for_user.id, actor_id: @project_for_user.id, action: "invite removed", notifiable: @project_for_user, reference: @user_two )
      assert_equal "invite removed", @project_for_user.notifications.first.action
    end
end
