class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.boolean :allow_rotation
      t.integer :cutting_width
      t.string :status
      t.decimal :efficiency
      t.integer :sheets_used
      t.integer :pieces_placed
      t.integer :pieces_total

      t.timestamps
    end
  end
end
