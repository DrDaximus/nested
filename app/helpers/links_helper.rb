module LinksHelper

	def link_status(link)
		if link.expires <= Time.now
			return "expired"
		elsif (link.expires - Time.now) <= 24
			return "ending"
		else 
			return "active"
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