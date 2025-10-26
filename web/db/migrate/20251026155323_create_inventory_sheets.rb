class CreateInventorySheets < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_sheets do |t|
      t.string :label
      t.decimal :width
      t.decimal :height
      t.decimal :thickness
      t.string :material
      t.integer :quantity
      t.integer :available_quantity

      t.timestamps
    end
  end
end
