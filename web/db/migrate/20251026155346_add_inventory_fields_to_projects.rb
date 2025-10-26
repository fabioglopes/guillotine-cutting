class AddInventoryFieldsToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :use_inventory, :boolean
    add_column :projects, :cut_completed, :boolean
    add_column :projects, :cut_completed_at, :datetime
  end
end
