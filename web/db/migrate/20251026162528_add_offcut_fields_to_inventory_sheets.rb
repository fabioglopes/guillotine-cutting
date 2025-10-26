class AddOffcutFieldsToInventorySheets < ActiveRecord::Migration[8.1]
  def change
    add_column :inventory_sheets, :is_offcut, :boolean
    add_column :inventory_sheets, :parent_sheet_id, :integer
    add_column :inventory_sheets, :source_project_id, :integer
  end
end
