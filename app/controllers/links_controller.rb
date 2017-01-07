class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_link, only: [:clicked_links, :show, :edit, :update, :destroy]
  before_action :clean_up, only: [:new, :show, :index]

  # GET /links
  # GET /links.json
  def index
    @links = current_user.links.all.order(subscribe_opt: :desc, expires: :desc)
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
    @link = current_user.links.new(subscribe_opt: params[:subscribe_opt])
    @code = Code.gen_code(@link.subscribe_opt)
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
        subscription_tasks(@link)
        code_tasks(@code)
        format.html { redirect_to @link, notice: 'Link was successfully created.' }
        format.json { render :show, status: :created, location: @link }
      else
        format.html { render :new }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  def code_tasks(code)
    code.available = false
    code.save
  end

  def subscription_tasks(link)
    if link.hold_token.present?
      current_user.token = link.hold_token
      current_user.save
      customer = Stripe::Customer.retrieve(current_user.stripeid)
      customer.source = link.hold_token # obtained with checkout
      customer.save
    end
    # Determin Subscription Type and set link expiry. Initialise subscription.
    sub_expire = (Time.now + 100.years)
    case link.subscribe_opt
      when 0
        link.expires = Time.now + 24.hours
        sub_id = "NestBasic"
      when 1
        link.expires = sub_expire
        sub_id = "6D"
      when 2
        link.expires = sub_expire
        sub_id = "5D"
      when 3
        link.expires = sub_expire
        sub_id = "4D"
    end
    # Check customer has been created on Stripe and create if not. Assign customer stripe_id to customer_id.
    unless current_user.subscribed
      customer = Stripe::Customer.create(:email => current_user.email)
      customer_id = customer.id
      current_user.subscribed = true 
      current_user.stripeid = customer_id
      current_user.save 
    else
      customer_id = current_user.stripeid
    end
      # Create subscription on Stripe using customer_id, plan and code.
      @subscription = Stripe::Subscription.create(:customer => customer_id, :plan => sub_id, :metadata => {"code" => @link.code})
      # Save subscription id to link.
      link.subscriptionid = @subscription.id
      link.save
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
    unless @link.expired?
      find_code
      @code.destroy
      end_subscription(@link)
    end
    @link.destroy
    respond_to do |format|
      format.html { redirect_to links_url, notice: 'Link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def end_subscription(link)
      subscription = Stripe::Subscription.retrieve(link.subscriptionid)
      subscription.delete
    end

    def clean_up
      expire_links
      Code.clean_codes
    end

    #Remove expired link codes and mark link as expired, end subscription on Stripe
    def expire_links
      links = current_user.links.expired
      links.each do |link|
        code = Code.where(code: link.code).first
        code.destroy
        end_subscription(@link)
        link.expired = true
        link.code = "expired"
        link.subscriptionid = nil
        link.save
      end  
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
      params.require(:link).permit(:title, :link, :code, :goal, :subscribe_opt, :expires, :expired, :hold_token)
    end
end