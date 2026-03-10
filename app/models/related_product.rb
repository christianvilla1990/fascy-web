class RelatedProduct < ApplicationRecord
  belongs_to :producto, class_name: 'Producto'
  belongs_to :related_producto, class_name: 'Producto'

  validates :producto_id, presence: true
  validates :related_producto_id, presence: true
  validate :cannot_relate_to_self
  validates :related_producto_id, uniqueness: { scope: :producto_id }

  def cannot_relate_to_self
    return unless producto_id.present? && related_producto_id.present?
    errors.add(:related_producto_id, "can't be the same as producto") if producto_id == related_producto_id
  end
end
