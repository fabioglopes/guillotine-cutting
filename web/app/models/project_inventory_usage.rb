class ProjectInventoryUsage < ApplicationRecord
  belongs_to :project
  belongs_to :inventory_sheet

  validates :quantity_used, numericality: { greater_than: 0 }
end
