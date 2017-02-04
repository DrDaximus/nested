module ApplicationHelper
	def stripe_to_cur(amount)
		amount = amount/100
		return "£" + amount.to_s
	end

	def link_to_unless(*args,&block)
	  args.insert 1, capture(&block) if block_given?

	  super *args
	end

	def smiley(status)
		if status == "active"
			"smile"
		elsif status == "ending"
			"meh"
		elsif status == "expired"
			"frown"
		end
	end
	
end
