require 'test_helper'
class SalesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = create(:user, name: "testsales")
    @board = create(:board, project: @user.projects.first)
    @admin = create(:user, name: "salesadmin", roles: "admin")
    sign_in @admin
  end

  test "can create sale" do
    post admin_sales_url, params: { sale: { description: "Sale test description",
                                            percent: "20",
                                            starts_at: "2020-11-07 21:12:39",
                                            ends_at: "2020-11-08 21:12:39",
                                            board_ids: [@board.id]} }
    assert 1, @board.sales.count
  end

  test "can delete sale" do
    @sale = create(:sale, board_ids: [@board.id])
    assert 1, @board.sales.count
    delete admin_sale_path(@sale)
    assert 0, @board.sales.count
  end
end
