class HomeController < ApplicationController
  def index
    @titulo = "Bienvenido a Fascy Web"
    # Solo categorías con productos destacados
    @categorias_destacadas = Categoria.joins(:productos).merge(Producto.destacados).distinct.order(:nombre)
    @productos_promo_mes = Producto.where(mas_vendido: true)
    @banners_principales = Banner.where(tipo: "principal").order(created_at: :desc)
    @banners_secundarios = Banner.where(tipo: "secundario").order(created_at: :desc)

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
    if params[:id] == 'destacados'
      @categoria = nil
      @subcategoria = nil
      @productos = Producto.destacados.order(:caracteristica)
      @pagy, @productos = pagy(@productos, items: 24)
    elsif params[:id] == 'promo_mes'
      @categoria = nil
      @subcategoria = nil
      @productos = Producto.where(mas_vendido: true).order(:caracteristica)
      @pagy, @productos = pagy(@productos, items: 24)
    elsif Categoria.exists?(params[:id])
      @categoria = Categoria.find(params[:id])
      subcategorias_ids = @categoria.subcategorias.pluck(:id)
      @productos = Producto.where(subcategoria_id: subcategorias_ids).order(:caracteristica)
      @pagy, @productos = pagy(@productos, items: 24)
    elsif Subcategoria.exists?(params[:id])
      @subcategoria = Subcategoria.find(params[:id])
      @pagy, @productos = pagy(@subcategoria.productos.order(:caracteristica), items: 24)
    else
      @categoria = nil
      @subcategoria = nil
      @productos = []
      @pagy, @productos = pagy(@productos, items: 24)
    end
    render layout: false if turbo_frame_request?
  end

  def productos_detalle
    @producto = Producto.with_attached_imagenes.find(params[:id])
    render layout: false if turbo_frame_request?
  end

end
