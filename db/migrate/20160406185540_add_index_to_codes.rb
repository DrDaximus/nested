class AddIndexToCodes < ActiveRecord::Migration
  def change
  	add_column :codes, :code, :integer
  	add_index :codes, :code, unique: true
  end
end
