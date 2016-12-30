module LinksHelper

	def link_status(link)
		if link.expired
			return "expired"
		elsif Time.now + 12.hours > link.expires
			return "ending"
		else 
			return "active"
		end
	end

	def link_expiry(link)
		if Time.now < link.expires
			"Expires in " + distance_of_time_in_words(Time.now, link.expires) 
		else
			"expired " + time_ago_in_words(link.expires) + " ago"
		end
	end

	def favicon_show(url)

		@fav = "http://www.google.com/s2/favicons?domain_url=" + url.link
		return @fav

	end

	def clicks_chart_data
		
		clicks = @clicks.group("Date(time)").select("Date(time) as day, count(*) as day_count")

	end
	def total_clicks
		total_clicks = @clicks.count
	end
	def goal_clicks
		total_clicks = @link.goal
	end
end