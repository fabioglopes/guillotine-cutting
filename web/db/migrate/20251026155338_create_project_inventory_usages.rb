class CreateProjectInventoryUsages < ActiveRecord::Migration[8.1]
  def change
    create_table :project_inventory_usages do |t|
      t.references :project, null: false, foreign_key: true
      t.references :inventory_sheet, null: false, foreign_key: true
      t.integer :quantity_used

      t.timestamps
    end
  end
end
