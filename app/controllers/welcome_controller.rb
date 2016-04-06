class WelcomeController < ApplicationController

	def index

    if !params[:search].blank?
      @link = Link.search(params[:search]).limit(1)
      if @link.count == 1
        ahoy.track "Viewed link", @link.first.id
      	params[:search] = ""
        @url = @link.first.link
        redirect_to @url
      elsif @link.count == 0 && !params[:search].blank?
      	flash[:notice] = "Sorry, that code can't be found in the Nest"
      	params[:search] = ""
      	redirect_to root_path
      end
    end
    
  end
	
end
