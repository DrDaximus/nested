class AddUserIdToLinksAndNameFieldsToUser < ActiveRecord::Migration
  def change
  	change_table :links do |t|
		  t.integer :user_id
		end

		change_table :users do |t|
		  t.string :name
		  t.string :lastname
		end
  end
end
