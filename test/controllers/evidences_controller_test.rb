require 'test_helper'

class EvidencesControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get evidence_update_url
    assert_response :success
  end

end
