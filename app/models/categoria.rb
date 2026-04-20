class Categoria < ApplicationRecord
    extend FriendlyId
    friendly_id :nombre, use: [:slugged, :history, :finders]

    has_many :subcategorias
    has_many :productos
    validates :nombre, presence: true
    has_one_attached :imagen

    def should_generate_new_friendly_id?
      nombre_changed? || slug.blank?
    end
end
