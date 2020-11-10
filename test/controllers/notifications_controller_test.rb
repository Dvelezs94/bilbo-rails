require 'test_helper'

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @name = "Notification"
    @project =  create(:project, name: @name)
    @user = create(:user,name: "Provider" , email: "#{name}@bilbo.mx".downcase, roles: "provider")
    @campaign = create(:campaign, name: "notif", project: @user.projects.first, project_id: @project.id, state: false)
    @board = create(:board,project: @user.projects.first, name: "Board", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
  end


  test 'index notifications' do
    sign_in @user
    get notifications_url
    assert_response :success
  end

  test 'clear notifications url' do
    sign_in @user
    get clear_notifications_url
    assert_response :redirect
  end

  test 'notification campaign created url' do
    sign_in @user
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 0)
    @notification = create(:notification, recipient_id: @project.id, actor_id: @campaign.project.id, action: "created", notifiable: @campaign)
    get provider_index_campaigns_url(q: "review")
    assert_response :success
  end

  test 'notification campaign approved url' do
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    @notification = create(:notification, recipient_id: @project.id, actor_id: @campaign.project.id, action: "approved", notifiable: @campaign, reference: @board)
    get analytics_campaign_url(@notification.notifiable.slug)
    assert_response :success
  end

  test 'notification campaign denied url' do
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 2)
    @notification = create(:notification, recipient_id: @project.id, actor_id: @campaign.project.id, action: "denied", notifiable: @campaign, reference: @board)
    get analytics_campaign_url(@notification.notifiable.slug)
    assert_response :success
  end

  test 'notification invite project' do
    @name_user_one = "Joaquin"
    @name_user_two = "Raul"
    @project_for_user =  create(:project, name: @name_user_one)
    @user_two = create(:user,name: @name_user_two , email: "#{@name_user_two}@bilbo.mx".downcase)
    sign_in @user_two
    @user_one = create(:user,name: @name_user_one , email: "#{@name_user_one}@bilbo.mx".downcase)
    @project_user = create(:project_user, role: @user_two.role, email: @user_two.email , project_id: @project_for_user.id)
    @notification = create(:notification, recipient_id: @project_for_user.id, actor_id: @project_for_user.id, action: "new invite", notifiable: @project_for_user, reference: @user_two )
    get change_project_project_url(@user_two.notifications.first.notifiable_id)
    assert_response :redirect
  end

  test 'notification remove project' do
    @name_user_two = "Raul"
    @project_for_user = create(:project, name: @name_user_two)
    @user_two = create(:user,name: @name_user_two , email: "#{@name_user_two}@bilbo.mx".downcase)
    @notification = create(:notification, recipient_id: @project_for_user.id, actor_id: @project_for_user.id, action: "invite removed", notifiable: @project_for_user, reference: @user_two )
    sign_in @user_two
    get change_project_project_url(@project_for_user.notifications.first.notifiable_id)
    assert_response :redirect
  end

  test 'notification out of credits' do
    @name_user_one = "Joaquin"
    @user_one = create(:user,name: @name_user_one , email: "#{@name_user_one}@bilbo.mx".downcase)
    @notification = create(:notification, recipient_id: @project.id, actor_id: @project.id, action: "out of credits", notifiable: @user_one)
    sign_in @user_one
    get campaigns_url(credits: "true")
    assert_response :success
  end

  test 'notification csv' do
    sign_in @user
    @report = create(:report, name: "report 1", project: @project)
    @notification = create(:notification, recipient_id: @project.id, actor_id: @project.id , action: "csv ready", notifiable: @user, reference: @project.reports.first)
    head download_csv_csv_index_url(reference: @project.reports.first.name), headers: { "Content-Type": "text/csv" }
    assert_response :success
  end
end
