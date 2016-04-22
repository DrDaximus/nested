class Link < ActiveRecord::Base

	belongs_to :user
	validates :code, presence: true
	validates_length_of :title, :maximum => 20

	def self.search(search)
	  where("code = ?", "#{search}") 
	end

end
