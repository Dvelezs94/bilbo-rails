require 'test_helper'

class AdsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, name: "Robin")
    sign_in @user
  end

  test "can get index" do
    get ads_url
    assert_response :success
  end

  test "can create and destroy ad" do
    @ad_name = "My awesome new ad"
    assert_difference 'Ad.count', 1 do
      post ads_url, params: { ad: { name: @ad_name } }
    end
    @ad = Ad.friendly.find(to_slug(@ad_name))
    assert_redirected_to ad_path(@ad.slug)

    delete ad_url(@ad.slug)

    assert "deleted", @ad.status
  end

  test "can update ad" do
    @ad =  create(:ad, name: "Ad ten", project: @user.projects.first)
    put ad_url(@ad.slug), params: { ad: { name: "Brand Ad", description: "The best Ad Ever" } }
    assert "Brand Ad", @ad.name
    assert "The best Ad Ever", @ad.description
  end

  test "can attach and delete multimedia" do
    @ad =  create(:ad, name: "Coca-Cola", project: @user.projects.first)
    assert 0, @ad.images.count
    @ad.multimedia.attach(
      io: File.open(Rails.root.join('test', 'fixtures', 'test_image.jpg')),
      filename: 'test_image.jpg',
      content_type: 'image/jpg'
    )
    assert 1, @ad.images.count

    assert_difference 'ActiveStorage::Blob.count', -1 do
      delete ad_attachment_path(@ad, @ad.images.first)
    end
  end

  test "Redirected if not logged in" do
    sign_out :user
    get ads_url
    assert_response :redirect
  end
end
