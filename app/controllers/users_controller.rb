class UsersController < ApplicationController
	before_filter :authenticate_user! 

	def show
		@user = current_user
			#customer = Stripe::Customer.retrieve(current_user.stripeid)
    	#customer.source = params[:stripeToken] # obtained with Stripe.js
    	#customer.save	
	end

end
