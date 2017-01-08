module LinksHelper

	def subscription(option)
		case option
		when 0
			"Basic Link"
		when 1
			"Silver Link"
		when 2
			"Bronze Link"
		when 3
			"Gold Link"
		end
	end

	def link_count(link)
		identifier = link.id.to_s + (link.created_at.to_i).to_s
    clicks = Ahoy::Event.where(properties: identifier)
    clicks.count
	end

	def link_status(link)
		# Capture error links that recieved no expiry on creation
		unless link.expires
			recover_expiry(link)
		end
		if link.expired
			return "expired"
		elsif Time.now + 1.hour > link.expires
			return "ending"
		else 
			return "active"
		end
	end

	def link_expiry(link)
		# Capture error links that recieved no expiry on creation
		sub = link.subscribe_opt
		unless link.expires
			recover_expiry(link)
		end
		unless sub == 0
			"#{subscription(sub)} Subscription"
		else
			if Time.now < link.expires
				"Expires in " + distance_of_time_in_words(Time.now, link.expires) 
			else
				"expired " + time_ago_in_words(link.expires) + " ago"
			end
		end
	end

	def recover_expiry(link)
		if link.subscribe_opt = 0
			link.expires = Time.now + 24.hours
		else
			link.expires = Time.now + 200.years
		end
		link.save
	end

	def favicon_show(url)
		@fav = "http://www.google.com/s2/favicons?domain_url=" + url.link
		return @fav

	end

	def link_life(link)
		hours = ((Time.now - link.created_at)/1.hours).round(1)
		days = ((Time.now - link.created_at)/1.days).round(1)
		if hours > 24
			return days.to_s + " Days"
		else 
			return hours.to_s + " Hours"
		end
	end

end