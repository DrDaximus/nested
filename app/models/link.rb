class Link < ActiveRecord::Base
	#attr_accessor :hold_token
	attr_accessor :coupon
	
	belongs_to :user
	validates :code, presence: true, uniqueness: true, on: :create
	validates :subscribe_opt, :title, :link, presence: true

	scope :active, -> { where(expired: false) }
	scope :expired, lambda { where('expires <= ? AND expired = ?', Time.now, false ) }

	def self.search(search)
	  where("code = ?", "#{search}") 
	end

	def gen_id
		#Generates a unique id for ahoy event captures. Id remains the same for each link. Rails id's get reused after destoy and cause issues with ahoy as it uses the record id. This creates a unique id for any created link. 
		return self.id.to_s + (self.created_at.to_i).to_s
	end

	def save_with_payment(customer, token, coupon)
		my_customer = customer
		if valid?
			stripe_customer = Stripe::Customer.retrieve(my_customer.stripeid)
			unless token == nil
				stripe_customer.source = token # obtained with checkout
	      stripe_customer.save
	    	#my_customer.token = token
	      #my_customer.save
    	end
      # Determin Subscription Type and set link expiry. Initialise subscription.
      sub_expire = (Time.now + 100.years)
    	case self.subscribe_opt
	      when 0
	        self.expires = Time.now + 24.hours
	        sub_id = "Basic"
	      when 1
	        self.expires = sub_expire
	        sub_id = "silver"
	      when 2
	        self.expires = sub_expire
	        sub_id = "bronze"
	      when 3
	        self.expires = sub_expire
	        sub_id = "gold"
    	end
      # Create subscription on Stripe using customer_id, plan and code.
      subscription = Stripe::Subscription.create(:customer => stripe_customer.id, :plan => sub_id, :coupon => coupon, :metadata => {"code" => self.code})
      # Save subscription id to link.
      self.subscriptionid = subscription.id
      save!
  	end
  rescue Stripe::InvalidRequestError => e
  	logger.error "Stripe error while creating customer: #{e.message}"
  	errors.add :base, "There was a problem with your subscription."
  	errors.add :base, "#{e.message}"
  	false
	end

end

	
