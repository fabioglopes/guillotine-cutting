class AddExactModeToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :exact_mode, :boolean, default: false, null: false
  end
end


