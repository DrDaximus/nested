class Link < ActiveRecord::Base
	attr_accessor :hold_token
	
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

end
