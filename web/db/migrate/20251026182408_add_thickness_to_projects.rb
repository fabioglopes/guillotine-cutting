class AddThicknessToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :thickness, :decimal
  end
end
