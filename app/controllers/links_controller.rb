class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_link, only: [:clicked_links, :show, :edit, :update, :destroy]

  # GET /links
  # GET /links.json
  def index
    @links = current_user.links.all
  end

  def preview_link
    @link = Link.find(params[:format])  
    @page = MetaInspector.new(@link.link)
  end

  # GET /links/1
  # GET /links/1.json
  def show
    @page = MetaInspector.new(@link.link)
    @clicks = Ahoy::Event.where(properties: @link.id)
  end
  
  # GET /links/new
  def new
    @code = Code.where(available: true).first
    @code.available = false
    @code.save
    @link = current_user.links.new
  end

  # GET /links/1/edit
  def edit
  end

  # POST /links
  # POST /links.json
  def create
    @link = current_user.links.new(link_params)
  
    respond_to do |format|
      if @link.save 
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
      params.require(:link).permit(:title, :link, :code, :code_id, :goal, :subscribe_opt)
    end
end