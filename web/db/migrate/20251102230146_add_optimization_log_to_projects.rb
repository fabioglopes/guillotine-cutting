class AddOptimizationLogToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :optimization_log, :text
  end
end
