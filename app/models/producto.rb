class Producto < ApplicationRecord
  belongs_to :marca, optional: true
  belongs_to :categoria, optional: true
  belongs_to :subcategoria, optional: true

  has_many_attached :imagenes

  scope :destacados, -> { where(destacado: true) }
  scope :mas_vendidos, -> { where(mas_vendido: true) }

    # Origen
  enum source: { manual: 0, api: 1 }, _prefix: true

    # replaces: validates :external_id, presence: true, uniqueness: true
  validates :external_id, uniqueness: true, allow_nil: true
  validates :external_id, presence: true, if: :source_api?

  
  # Punto 4: método portada
  def portada
    return unless imagenes.attached?
    imagenes.find { |att| att.filename.to_s.downcase =~ /(portada|cover|principal|main)/ } ||
      imagenes.find { |att| att.filename.to_s.downcase =~ /foto[_-]?0?1/ } ||
      imagenes.first
  end
  
  def imagen_portada
  return unless respond_to?(:imagenes) && imagenes.attached?
  imagenes.find { |a| a.filename.to_s =~ /-1\.(jpe?g|png|webp|gif|avif|bmp)\z/i } || imagenes.first
  end


  def otras_imagenes
    return [] unless imagenes.attached?
    portada = imagen_portada
    imagenes.reject { |att| att == portada }
  end

 

end
