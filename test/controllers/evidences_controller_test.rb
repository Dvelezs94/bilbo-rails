require 'test_helper'

class EvidencesControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get evidences_update_url
    assert_response :success
  end

end
