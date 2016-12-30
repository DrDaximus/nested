namespace :codes do

	desc "Clean up codes that are unused but marked as unavailable"
	task clean: :environment do
    p "Cleaning up unused codes..."
    codes = Code.dirty
    codes.each do |code|
    	code.available = false
    	code.save
    end
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
    codes = Code.available.count
    p ">> Available codes = #{codes}"
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

