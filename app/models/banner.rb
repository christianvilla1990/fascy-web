class Banner < ApplicationRecord
	has_one_attached :imagen
	has_one_attached :imagen_mobile
end
