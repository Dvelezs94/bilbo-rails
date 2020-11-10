class BoardSale < ApplicationRecord
  belongs_to :board
  belongs_to :sale
  validate :not_other_sale_running

  private
  def not_other_sale_running
    if board.sales.running.present?
      errors.add(:base, "El bilbo #{board.name} ya tiene ofertas corriendo")
    end
  end
end
