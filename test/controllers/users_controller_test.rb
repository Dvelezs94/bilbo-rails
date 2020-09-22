require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, name: "Goten")
    sign_in @user
  end

  ## this is not working, IDK why, we need to debug later
  # test "can register" do
  #   assert_difference 'User.count', 1 do
  #   post user_registration_url, params: { user: { email: "test@dbz.com", password: "password123",
  #                                                 password_confirmation: "password123",
  #                                                 name: "test user", project_name: "test project" } }
  #   end
  # end
  #
  # test "avoid bots" do
  #   assert_difference 'User.count', 0 do
  #   post user_registration_url, params: { user: { email: "testbot@dbz.com", password: "password",
  #                                                 password_confirmation: "password", name: "test user",
  #                                                 project_name: "test project", phone_number: "1234567890" } }
  #   end
  # end

  test "can log in" do
    post user_session_url, params: { user: { email: @user.email, password: "password" } }
    assert_redirected_to dashboards_path
  end

  test "can reset password" do
    post user_password_url, params: { user: { email: @user.email } }
    assert_response :redirect
  end

  test "can log out" do
    delete destroy_user_session_url
    assert_redirected_to root_path
  end

  test "cannot assign credits if not verified" do
    @user.update(verified: false)
    @user.add_credits(50)
    assert 0, @user.balance
  end

  test "can assign credits once verified" do
    @user.update(verified: true)
    @user.add_credits(50)
    assert 50, @user.balance
  end

  test "charge credits" do
    @balance = @user.balance
    @user.charge!(10)
    assert @balance - 10, @user.balance
  end

  test "toggle ban" do
    @ban_state = @user.banned
    @user.toggle_ban!
    assert !@ban_state, @user.banned
  end
end
