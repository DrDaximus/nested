class AddSubscribeOptToLinks < ActiveRecord::Migration
  def change
  	add_column :links, :subscribe_opt, :integer, :default => 0
  end
end
