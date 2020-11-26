require 'test_helper'

class VerificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @name = "Bilbo verification controller"
    @user = create(:user, name: @name, email: "usercontroller@bilbo.mx")
    @verification = create(:verification, user_id: @user.id, name: @name, official_id: {io: File.open('app/assets/images/placeholder_active_storage.png'), filename: 'placeholder.png', content_type: 'image/png'}, business_name: "Bilbo", street_1: "Salvador 529", street_2: "Gonzalez Lobo", city: "Saltillo", state: "Coahuila", zip_code: 24883, country: "MX", rfc: nil, business_code: "", official_business_name: "", website: "http://bilbo.mx", phone: "999-999-9999", status: "pending")
    sign_in @user
  end

  test "create redirect" do
    post verification_url, params: { verification: { user_id: @user.id, name: @name, official_id: {io: File.open('app/assets/images/placeholder_active_storage.png'), filename: 'placeholder.png', content_type: 'image/png'}, business_name: "Bilbo", street_1: "Salvador 529", street_2: "Gonzalez Lobo", city: "Saltillo", state: "Coahuila", zip_code: 24883, country: "MX", rfc: nil, business_code: "", official_business_name: "", website: "http://bilbo.mx", phone: "999-999-9999", status: "pending"}}
    assert_response :redirect
  end

  test "only one verification when create two verifications" do
    post verification_url, params: { verification: { user_id: @user.id, name: @name, official_id: {io: File.open('app/assets/images/placeholder_active_storage.png'), filename: 'placeholder.png', content_type: 'image/png'}, business_name: "Bilbo", street_1: "Salvador 529", street_2: "Gonzalez Lobo", city: "Saltillo", state: "Coahuila", zip_code: 24883, country: "MX", rfc: nil, business_code: "", official_business_name: "", website: "http://bilbo.mx", phone: "999-999-9999", status: "pending"}}
    post verification_url, params: { verification: { user_id: @user.id, name: @name, official_id: {io: File.open('app/assets/images/placeholder_active_storage.png'), filename: 'placeholder.png', content_type: 'image/png'}, business_name: "Bilbo", street_1: "Salvador 529", street_2: "Gonzalez Lobo", city: "Saltillo", state: "Coahuila", zip_code: 24883, country: "MX", rfc: nil, business_code: "", official_business_name: "", website: "http://bilbo.mx", phone: "999-999-9999", status: "pending"}}
    assert_equal 1, @user.verifications.count
    assert_response :redirect
  end

  test "user verification accepted" do
    @verification
    @user.verifications.last.accepted!
    assert_equal "accepted", @user.verifications.last.status
  end

  test "user verified and change of status from campaign to true" do
    @verification
    @user.verifications.last.accepted!
    @user.update(verified: true)
    @ad = create(:ad, name: "Coca-Cola", project_id: @user.projects.last.id)
    @board = create(:board, project_id: @user.projects.last.id, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @camp1 = create(:campaign, name: "on", project_id: @user.projects.last.id, description: nil, state: false, ad_id: @ad.id, budget: 100, clasification: "budget", boards: [@board], budget: 350, state_updated_at: nil, status: "active")
    assert true, @camp1.on
  end

end
