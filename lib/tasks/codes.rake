namespace :codes do
  desc "TODO"
  task seed_codes: :environment do

		index = 10000

  	100.times do
  		
  		Code.create!(code: index)
      index = index + 1

		end

		p "Created #{Code.count} codes"

  end

end
