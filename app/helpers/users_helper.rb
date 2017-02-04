module UsersHelper
	def instruct
		# use to test if user has links and registered less than a month ago for the sake of showing instructions. 
		instruct = false
		instruct = true if current_user.links.count >= 1 && current_user.created_at < 1.month.ago
		return instruct
	end
end
