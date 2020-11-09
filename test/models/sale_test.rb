require 'test_helper'

class SaleTest < ActiveSupport::TestCase
  setup do
    @project =  create(:project, name: "Project Sales")
    @board_1 = create(:board, project: @project)
    @board_2 = create(:board, project: @project)
  end

  test 'Can create Sale' do
    @sale = create(:sale, board_ids: [@board_1.id, @board_2.id])
    assert 2, @sale.boards.count
  end

  test 'Can not create duplicate sale' do
    @sale = create(:sale, board_ids: [@board_1.id, @board_2.id])
    assert 1, Sale.count
  end

  # test 'Can not create sale with end date before start date' do
  #   @board_4 = create(:board, project: @project)
  #   @sale = create(:sale, board_ids: [@board_4.id], starts_at: "2020-11-07 21:12:39", ends_at: "2020-11-06 21:12:39")
  #   assert 1, Sale.count
  # end

  test 'Can create another sale with different boards' do
    @board_3 = create(:board, project: @project)
    @sale = create(:sale, board_ids: [@board_3.id])
    assert 1, @sale.boards.count
    assert 2, Sale.count
  end
end
