class InventorySheet < ApplicationRecord
  has_many :project_inventory_usages, dependent: :destroy
  has_many :projects, through: :project_inventory_usages
  
  # Sobras/retalhos
  belongs_to :parent_sheet, class_name: 'InventorySheet', optional: true
  belongs_to :source_project, class_name: 'Project', optional: true
  has_many :offcuts, class_name: 'InventorySheet', foreign_key: 'parent_sheet_id', dependent: :destroy

  validates :label, presence: true
  validates :width, :height, :thickness, numericality: { greater_than: 0 }
  validates :quantity, :available_quantity, numericality: { greater_than_or_equal_to: 0 }
  
  before_validation :set_available_quantity, on: :create
  before_validation :set_offcut_defaults, if: :is_offcut?

  scope :available, -> { where('available_quantity > 0') }
  scope :by_material, ->(material) { where(material: material) if material.present? }
  scope :offcuts, -> { where(is_offcut: true) }
  scope :standard, -> { where(is_offcut: [false, nil]) }

  def dimensions
    "#{width} × #{height}mm"
  end

  def description
    "#{label} - #{dimensions} - #{thickness}mm #{material}"
  end

  def in_stock?
    available_quantity > 0
  end

  def reserve!(quantity)
    if available_quantity >= quantity
      update!(available_quantity: available_quantity - quantity)
      true
    else
      false
    end
  end

  def release!(quantity)
    update!(available_quantity: [available_quantity + quantity, self.quantity].min)
  end

  def offcut?
    is_offcut == true
  end

  private

  def set_available_quantity
    self.available_quantity ||= self.quantity
  end

  def set_offcut_defaults
    # Sobras sempre têm quantidade = available_quantity = 1
    self.quantity ||= 1
    self.available_quantity ||= 1
  end
end
