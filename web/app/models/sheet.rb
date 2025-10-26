class Sheet < ApplicationRecord
  belongs_to :project

  validates :width, numericality: { greater_than: 0 }, allow_nil: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true
  validates :quantity, numericality: { greater_than: 0 }, allow_nil: true

  before_validation :set_defaults, on: :create

  private

  def set_defaults
    self.quantity ||= 1
  end
end
