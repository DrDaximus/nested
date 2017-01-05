class Code < ActiveRecord::Base

	scope :unused_codes, lambda {find_by_sql('SELECT codes.* FROM codes WHERE code NOT IN(SELECT code FROM links)')}
	scope :used_codes, lambda {find_by_sql('SELECT codes.* FROM codes WHERE code IN(SELECT code FROM links)')}
	scope :dirty, lambda {find_by_sql ["SELECT * FROM codes WHERE code IN(SELECT code FROM links) AND available = ?", true] }
	scope :available, -> { where(available: true) }
	
	# On creation of a new link, a new code is generated dependng on the subscription chosen.
	def self.gen_code
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
        newcode = Random.rand(bottom...top)
        gen_code if Code.exists?(code: newcode)
        code = Code.create(code: newcode)
        return code
      else
        redirect_to links_path, notice: "Oops... we seem to be short on codes, please try again shortly"
      end
    end

    #Checks for available codes and destroys.
    def self.clean_codes
      #Remove any dirty codes (Unused codes generated in error)
      codes = Code.available
      codes.each do |code|
        code.destroy
      end
    end

end
