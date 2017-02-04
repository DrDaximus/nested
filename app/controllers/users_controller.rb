class UsersController < ApplicationController
	before_filter :authenticate_user! 
	before_action :find_user, only: [:show, :cancel_sub]

	def show
		if @user.stripid 
			customer = Stripe::Customer.retrieve(@user.stripeid)
			@subs = Stripe::Subscription.list(:customer => customer)
			@canceledsubs = Stripe::Subscription.list(:customer => customer, :status => "canceled")
			@links = @user.links.order(expires: :desc)
			@activelinks = @links.active.order(expires: :desc)
		end
	end

	def cancel_sub
		@sub_id = params[:format]
		sub = Stripe::Subscription.retrieve(@sub_id)
		@link = Link.where(code: sub.metadata.code).first
		@link.end_subscription
		redirect_to @user, notice: "Your subscription was succesfully cancelled"
	end

	private

	def find_user
		@user = current_user
	end

end
