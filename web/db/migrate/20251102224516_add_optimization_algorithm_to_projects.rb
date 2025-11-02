class AddOptimizationAlgorithmToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :optimization_algorithm, :string, default: 'two_stage_guillotine'
  end
end
