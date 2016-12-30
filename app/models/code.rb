class Code < ActiveRecord::Base

	scope :unused_codes, lambda {find_by_sql('SELECT codes.* FROM codes WHERE code NOT IN(SELECT code FROM links)')}
	scope :used_codes, lambda {find_by_sql('SELECT codes.* FROM codes WHERE code IN(SELECT code FROM links)')}
	scope :dirty, lambda {find_by_sql ["SELECT * FROM codes WHERE code IN(SELECT code FROM links) AND available = ?", true] }
	#scope :available, -> { where(available: true) }
	
end
