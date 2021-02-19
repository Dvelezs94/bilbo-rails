require 'test_helper'

class VerificationTest < ActiveSupport::TestCase
  setup do
    @name = "Bilbo verification"
    @user = create(:user, name: @name, verified: false, email: "user@bilbo.mx")
    @verification = create(:verification, user_id: @user.id, name: @name, official_id: {io: File.open('app/assets/images/placeholder_active_storage.png'), filename: 'placeholder.png', content_type: 'image/png'}, business_name: "Bilbo", street_1: "Salvador 529", street_2: "Gonzalez Lobo", city: "Saltillo", state: "Coahuila", zip_code: 24883, country: "MX", rfc: nil, business_code: "", official_business_name: "", website: "http://bilbo.mx", phone: "999-999-9999", status: "pending")
  end

  test "create verification" do
    assert_equal 1, @user.verifications.count
  end

  test "pending status" do
    assert_equal "pending", @verification.status
  end

  test "has name" do
    assert_equal "Bilbo verification", @verification.name
  end

  test "has official_id" do
    assert_not nil, @verification.official_id
  end

  test "has user_id" do
    assert_not nil, @verification.user_id
  end

  test "has business_name" do
    assert_not nil, @verification.business_name
  end

  test "has street_1" do
    assert_not nil, @verification.street_1
  end

  test "has city" do
    assert_not nil, @verification.city
  end

  test "has state" do
    assert_not nil, @verification.state
  end

  test "has zip_code" do
    assert_not nil, @verification.zip_code
  end

  test "has phone" do
    assert_not nil, @verification.phone
  end

  test "user verified" do
    @user_two = create(:user, name: "Sasuke")
    assert_equal true, @user_two.verified
  end

  test "user not verified" do
    assert_equal false, @user.verified
  end

  test "active campaign when user is not verified" do
    @project =  create(:project, name: @name)
    @ad = create(:ad, name: "Coca-Cola", project_id: @user.projects.last.id)
    @board = create(:board, project_id: @user.projects.last.id, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @camp1 = create(:campaign, name: "on", project_id: @user.projects.last.id, description: nil, state: false, ad_id: @ad.id, budget: 100, classification: "budget", boards: [@board], budget: 350, state_updated_at: nil, status: "active", provider_campaign: @user.is_provider?)
    assert_equal false, @camp1.on
  end
end
