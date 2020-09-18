require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @name = "Vegeta"
    @user = create(:user, name: @name)
  end

  test "has name" do
    assert_equal @name, @user.name
  end

  test "has project name" do
    assert_equal @name, @user.projects.first.name
  end

  test "is user" do
    assert @user.is_user?
  end

  test "is provider" do
    @provider = create(:user, name: "provider", roles: "provider")
    assert @provider.is_provider?
  end

  test "is admin" do
    @provider = create(:user, name: "admin", roles: "admin")
    assert @provider.is_admin?
  end
end
