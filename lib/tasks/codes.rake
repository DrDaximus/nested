namespace :codes do

	desc "Clean up codes that are unused/dirty/expired"
	task clean: :environment do
    p "Starting clean..."
    p "Removing unused codes"
    codes = Code.unused_codes
    dcount = 0
    codes.each do |code|
    	code.destroy
      dcount = dcount + 1 
    end
    p ">> Destroyed #{dcount} of #{codes.count} unused codes"

    p "Altering dirty codes"
    codes = Code.dirty
    acount = 0
    codes.each do |code|
      code.available = false
      code.save
      acount = acount + 1 
    end
    p ">> Altered #{acount} of #{codes.count} dirty codes"

    p "Removing expired codes"
    links = Link.expired
    p "Expiring #{links.count} links..."
    links.each do |link|
      code = Code.where(code: link.code).first
      code.destroy
      link.expired = true
      link.code = ""
      link.save
    end
    p ">> Expired #{links.count} codes"

    p "Done!"
  end

	desc "Show code usages"
	task stats: :environment do
    p "Checking current code usage..."
    codes = Code.count
    p ">> Total codes = #{codes}"
     codes = Code.used_codes.count
    p ">> Used codes = #{codes}"
    codes = Code.unused_codes.count
    p ">> Unused codes = #{codes}"
    codes = Code.dirty.count
    p ">> Dirty codes = #{codes}"
  end

  desc "Generate codes 100000 - 100100"
  task batch1: :environment do
  	
  	index = 100000

  	100.times do
  		
  		Code.create!(code: index)
      index = index + 1

		end

		p "Created #{Code.count} codes"

  end

end

