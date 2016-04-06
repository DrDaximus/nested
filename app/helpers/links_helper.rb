module LinksHelper

def favicon_show(url)

	@fav = "http://www.google.com/s2/favicons?domain_url=" + url.link
	return @fav

end
	
end
