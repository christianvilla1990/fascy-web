class Subcategoria < ApplicationRecord
    extend FriendlyId
    friendly_id :nombre, use: [:slugged, :history, :finders]

    belongs_to :categoria, optional: true
    has_many :productos
    validates :nombre, presence: true

    def should_generate_new_friendly_id?
      nombre_changed? || slug.blank?
    end
end
