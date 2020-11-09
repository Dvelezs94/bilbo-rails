class Sale < ApplicationRecord
  has_many :board_sales, dependent: :destroy
  has_many :boards, through: :board_sales

  validates_presence_of :starts_at, :ends_at, :percent, :description
  validate :date_is_possible?
  validate :percent_is_acceptable?
  scope :running, -> { where("starts_at <= ? AND ends_at >= ?", Time.zone.now, Time.zone.now)}
  scope :stopped, -> { where("starts_at < ? AND ends_at < ?", Time.zone.now, Time.zone.now)}
  scope :scheduled, -> { where("starts_at > ? AND ends_at > ?", Time.zone.now, Time.zone.now)}


  def status
    current_time = Time.zone.now
    if starts_at <= current_time && ends_at >= current_time
      "running"
    elsif starts_at < current_time && ends_at < current_time
      "stopped"
    elsif starts_at > current_time && ends_at > current_time
      "scheduled"
    end
  end

  private

  def date_is_possible?
    if starts_at > ends_at
      errors.add(:base, "El inicio debe ser menor al fin de la fecha")
    end
  end

  def percent_is_acceptable?
    if !(percent > 0 && percent <= 100) 
      errors.add(:base, "El valor no es correcto")
    end
  end
end
