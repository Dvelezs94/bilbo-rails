require 'test_helper'

class WitnessesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get witnesses_new_url
    assert_response :success
  end

  test "should get create" do
    get witnesses_create_url
    assert_response :success
  end

  test "should get edit" do
    get witnesses_edit_url
    assert_response :success
  end

  test "should get index" do
    get witnesses_index_url
    assert_response :success
  end

end
