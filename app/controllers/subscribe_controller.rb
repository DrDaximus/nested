class SubscribeController < ApplicationController
  before_filter :authenticate_user! 
end
