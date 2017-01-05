class AddSubscriptionIdToLinks < ActiveRecord::Migration
  def change
  	add_column :links, :subscriptionid, :string 
  end
end
