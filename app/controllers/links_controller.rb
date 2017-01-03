class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_link, only: [:clicked_links, :show, :edit, :update, :destroy]

  # GET /links
  # GET /links.json
  def index
    clean_codes
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
    @identifier = @link.id.to_s + (@link.created_at.to_i).to_s
    @clicks = Ahoy::Event.where(properties: @identifier)
  end
  
  # GET /links/new
  def new
    @link = current_user.links.new
    @code = gen_code
  end

  # GET /links/1/edit
  def edit
  end

  # POST /links
  # POST /links.json
  def create
    @link = current_user.links.new(link_params)
    @code = Code.where(code: @link.code).first
    respond_to do |format|
      if @link.save 
        @code.available = false
        @code.save
        subscribe(@link)
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
    @link.destroy
    respond_to do |format|
      format.html { redirect_to links_url, notice: 'Link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def clean_codes
      links = current_user.links.expired
      links.each do |link|
        code = Code.where(code: link.code).first
        code.destroy
        link.expired = true
        link.code = ""
        link.save
      end   
    end

    def gen_code
      #Count total codes generated and then compare to total producable codes to see how short on codes we are.
      codes = Code.count 
      # Use the following in some way to facilitate subscription tiers.
      #if current_user.basic
        bottom = 100000
        top = 999999
      #elsif current_user.bronze
        #bottom = 10000
        #top = 99999
      #elsif current_user.silver
        #bottom = 10000
        #top = 99999
      #elsif current_user.gold
        #bottom = 1000
        #top = 9999
      #elsif current_user.platinum
        #bottom = 999
        #top = 100
      #reserved
        #bottom = 99
        #top = 1
      #end
      range = top - bottom
      # Unless there are more than 5 codes left to produce, don't produce any more. 
      unless range - codes < 5
        code = Random.rand(bottom...top)
        gen_code if Code.exists?(code: code)
        Code.create(code: code)
        return code
      else
        redirect_to links_path, notice: "Oops... we seem to be short on codes, please try again shortly"
      end
    end

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
      Stripe::Subscription.create(:customer => customer_id, :plan => plan, :metadata => {"code" => @link.code})
      
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