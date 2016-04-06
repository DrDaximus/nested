class Code < ActiveRecord::Base

scope :unused_codes, lambda {
    find_by_sql('SELECT codes.* FROM codes WHERE code NOT IN(SELECT code FROM links)LIMIT 10')
  }
	
end
