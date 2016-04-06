class Link < ActiveRecord::Base

	belongs_to :user
	validates :code, presence: true

	def self.search(search)
	  where("code = ?", "#{search}") 
	end

end
