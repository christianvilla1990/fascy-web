class Banner < ApplicationRecord
	has_one_attached :imagen
	# mobile variant attached by admin form
	has_one_attached :imagen_mobile
end
