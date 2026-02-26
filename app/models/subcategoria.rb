class Subcategoria < ApplicationRecord
    belongs_to :categoria, optional: true
    has_many :productos
    validates :nombre, presence: true
end
