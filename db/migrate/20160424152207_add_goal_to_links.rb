class AddGoalToLinks < ActiveRecord::Migration
  def change
  	add_column :links, :goal, :integer, :default => 0
  end
end
