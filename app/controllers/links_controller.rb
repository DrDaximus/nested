class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_link, only: [:clicked_links, :show, :edit, :update, :destroy]
  before_action :clean_up, only: [:new, :show, :index]

  # GET /links
  # GET /links.json
  def index
    @links = current_user.links.all.order(expires: :desc)
  end

  def preview_link
    @link = Link.find(params[:format])  
    #@page = MetaInspector.new(@link.link)
  end

  # GET /links/1
  # GET /links/1.json
  def show
    #@page = MetaInspector.new(@link.link)
    @link_id = @link.gen_id
    @clicks = Ahoy::Event.where(properties: @link_id)
  end
  
  # GET /links/new
  def new
    @link = current_user.links.new
    @code = Code.gen_code
  end

  # GET /links/1/edit
  def edit
  end

  # POST /links
  # POST /links.json
  def create
    @link = current_user.links.new(link_params)
    find_code
    respond_to do |format|
      if @link.save 
        subscribe(@link)
        @code.available = false
        @code.save
        format.html { redirect_to @link, notice: 'Link was successfully created.' }
        format.json { render :show, status: :created, location: @link }
      else
        format.html { render :new }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /links/1
  # PATCH/PUT /links/1.json
  def update
    respond_to do |format|
      if @link.update(link_params)
        format.html { redirect_to @link, notice: 'Link was successfully updated.' }
        format.json { render :show, status: :ok, location: @link }
      else
        format.html { render :edit }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    if @link.expired == false
      find_code
      @code.destroy
    end
    subscription = Stripe::Subscription.retrieve(@link.subscriptionid)
    subscription.delete
    @link.destroy
    respond_to do |format|
      format.html { redirect_to links_url, notice: 'Link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def clean_up
      expire_links
      Code.clean_codes
    end

    #Remove expired link codes and mark link as expired
    def expire_links
      links = current_user.links.expired
      links.each do |link|
        code = Code.where(code: link.code).first
        code.destroy
        link.expired = true
        link.code = ""
        link.save
      end  
    end
      
    # Run customer subscription process when link created.
    def subscribe(link)
      case link.subscribe_opt
      when 0
        link.expires = Time.now + 24.hours
        init_subscription("NestBasic")
      when 1
        link.expires = Time.now + 1.week
        init_subscription("NestWeekCode")
      when 2
        link.expires = Time.now + 1.month
        init_subscription("NestMonthCode")
      when 3
        link.expires = Time.now + 1.year
        init_subscription("NestYearCode")
      end
      link.subscriptionid = @subscription.id
      link.save
    end

    def init_subscription(plan)
      unless current_user.subscribed
        customer = Stripe::Customer.create(:email => current_user.email)
        customer_id = customer.id
        current_user.subscribed = true 
        current_user.stripeid = customer_id
        current_user.save 
      else
        customer_id = current_user.stripeid
      end
      @subscription = Stripe::Subscription.create(:customer => customer_id, :plan => plan, :metadata => {"code" => @link.code})
      
    end

    def find_code
      @code = Code.where(code: @link.code).first
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_link
      @link = Link.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def link_params
      params.require(:link).permit(:title, :link, :code, :goal, :subscribe_opt, :expires, :expired)
    end
end