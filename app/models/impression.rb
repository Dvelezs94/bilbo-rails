class Impression < ApplicationRecord
  belongs_to :board
  belongs_to :campaign, optional: true
  before_create :set_total_price

  private

  def set_total_price
    self.total_price = (board.cycle_price * cycles).round(3)
  end

end
