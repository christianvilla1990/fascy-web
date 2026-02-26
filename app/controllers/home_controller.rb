class HomeController < ApplicationController
  def index
    @titulo = "Bienvenido a Fascy Web"
    # Solo categorías con productos destacados
    @categorias_destacadas = Categoria.joins(:productos).merge(Producto.destacados).distinct.order(:nombre)
    @productos_promo_mes = Producto.where(mas_vendido: true)
    @banners_principales = Banner.all
    @banners_secundarios = []

    if params[:categoria].present?
      @productos_destacados = Producto.destacados.where(categoria_id: params[:categoria])
    else
      @productos_destacados = Producto.destacados
    end

    respond_to do |format|
      format.html
      format.turbo_stream { render partial: "home/productos_destacados", locals: { productos: @productos_destacados } }
    end
  end

  def categoria
    @subcategoria = Subcategoria.find(params[:id])
    
    @pagy, @productos = pagy(@subcategoria.productos.order(:caracteristica), items: 24)
    render layout: false if turbo_frame_request?
  end

  def productos_detalle
    @producto = Producto.with_attached_imagenes.find(params[:id])
    render layout: false if turbo_frame_request?
  end

end
