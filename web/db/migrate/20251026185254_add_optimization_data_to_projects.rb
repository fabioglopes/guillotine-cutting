class AddOptimizationDataToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :optimization_data, :text
  end
end
