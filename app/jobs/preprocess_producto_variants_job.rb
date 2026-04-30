class PreprocessProductoVariantsJob < ApplicationJob
  queue_as :default

  VARIANT_SIZES = [
    [120, 120],   # thumbnails (gallery, dashboard)
    [400, 400],   # listings (categoría / búsqueda)
    [600, 600],   # detail-side
    [800, 800]    # detail-main
  ].freeze

  def perform(producto_id)
    producto = Producto.find_by(id: producto_id)
    return unless producto
    portada = producto.imagen_portada
    return unless portada

    VARIANT_SIZES.each do |w, h|
      begin
        portada.variant(resize_to_limit: [w, h]).processed
      rescue => e
        Rails.logger.warn("[variants] producto=#{producto_id} size=#{w}x#{h}: #{e.message}")
      end
    end
  end
end
