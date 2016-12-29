class AddExpiresToLinks < ActiveRecord::Migration
  def change
  	add_column :links, :expires, :datetime
  end
end
