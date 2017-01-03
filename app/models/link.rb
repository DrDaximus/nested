class Link < ActiveRecord::Base
	
	belongs_to :user
	validates :code, presence: true, uniqueness: true, on: :create

	scope :expired, lambda { where('expires <= ? AND expired == ?', Time.now, false ) }

	def self.search(search)
	  where("code = ?", "#{search}") 
	end

end
