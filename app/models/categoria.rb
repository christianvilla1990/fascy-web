class Categoria < ApplicationRecord
    has_many :subcategorias
    has_many :productos
    validates :nombre, presence: true
    has_one_attached :imagen
end
