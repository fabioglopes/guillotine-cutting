class Project < ApplicationRecord
  has_many :sheets, dependent: :destroy
  has_many :pieces, dependent: :destroy
  has_one_attached :input_file
  has_many_attached :result_files

  accepts_nested_attributes_for :sheets, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :pieces, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :cutting_width, numericality: { greater_than: 0 }, allow_nil: true
  validates :status, inclusion: { in: %w[draft pending processing completed error] }, allow_nil: true

  before_validation :set_defaults, on: :create

  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }

  def optimized?
    status == 'completed'
  end

  def can_optimize?
    (sheets.any? || input_file.attached?) && pieces.any?
  end

  private

  def set_defaults
    self.allow_rotation = true if allow_rotation.nil?
    self.cutting_width ||= 3
    self.status ||= 'draft'
  end
end
