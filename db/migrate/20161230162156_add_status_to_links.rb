class AddStatusToLinks < ActiveRecord::Migration
  def change
  	add_column :links, :expired, :boolean, :default => false
  end
end
