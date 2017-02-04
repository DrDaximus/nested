class WelcomeController < ApplicationController

	def index

    if !params[:search].blank?
      @links = Link.search(params[:search]).limit(1)
      @link = @links.first
      if @link
        #Create an ahoy event using the gen_id link method as an identifier.
        ahoy.track "Viewed link", @link.gen_id
      	params[:search] = ""
        @url = "http://www." + @link.link
        redirect_to @url
      else
      	flash[:notice] = "Sorry, that code is either invalid or expired. Please check and try again!"
      	params[:search] = ""
      	redirect_to root_path
      end
    end
    
  end
	
end
