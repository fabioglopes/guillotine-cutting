class CreateSheets < ActiveRecord::Migration[8.1]
  def change
    create_table :sheets do |t|
      t.references :project, null: false, foreign_key: true
      t.string :label
      t.integer :width
      t.integer :height
      t.decimal :thickness
      t.integer :quantity

      t.timestamps
    end
  end
end
