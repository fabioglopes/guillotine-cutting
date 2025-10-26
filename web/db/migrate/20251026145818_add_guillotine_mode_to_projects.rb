class AddGuillotineModeToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :guillotine_mode, :boolean
  end
end
