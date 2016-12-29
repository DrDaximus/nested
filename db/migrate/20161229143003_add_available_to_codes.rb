class AddAvailableToCodes < ActiveRecord::Migration
  def change
  	add_column :codes, :available, :boolean, :default => true
  end
end
