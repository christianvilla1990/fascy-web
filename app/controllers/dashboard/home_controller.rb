class Dashboard::HomeController < Dashboard::BaseController
  def index
    @stats = {
      productos:            Producto.count,
      productos_destacados: Producto.where(destacado: true).count,
      productos_promo:      Producto.where(mas_vendido: true).count,
      categorias:           Categoria.count,
      subcategorias:        Subcategoria.count,
      banners:              Banner.count
    }
    @ultimos_productos = Producto.with_attached_imagenes.order(updated_at: :desc).limit(5)
  end
end
