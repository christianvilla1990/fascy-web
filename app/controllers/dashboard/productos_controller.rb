class Dashboard::ProductosController < Dashboard::BaseController
  before_action :set_producto, only: %i[show edit update destroy]
  before_action :load_collections, only: %i[new edit create update]

  def load_collections
    @marcas        = Marca.order(:nombre)
    @categorias    = Categoria.order(:nombre)
    @subcategorias = Subcategoria.order(:nombre)
    @productos     = Producto.order(:caracteristica).to_a
  end

  def index
    @q = params[:q].to_s.strip
    scope = Producto.order(created_at: :desc)
                         .includes(:marca, :categoria, :subcategoria, imagenes_attachments: :blob)

    if @q.present?
      q = "%#{@q.downcase}%"
      scope = scope.left_joins(:marca, :categoria, :subcategoria)
                   .where(
                     "LOWER(productos.external_id) LIKE :q OR LOWER(productos.sku) LIKE :q OR LOWER(productos.caracteristica) LIKE :q OR LOWER(marcas.nombre) LIKE :q OR LOWER(categorias.nombre) LIKE :q OR LOWER(subcategorias.nombre) LIKE :q",
                     q: q
                   )
    end



    per_page = params[:per_page].to_i
    per_page = 20 if per_page <= 0 || per_page > 100

    @pagy, @productos = pagy(scope, items: per_page)

  end

  def show; end

  def new
    @producto = Producto.new(source: :manual)
  end

  def edit; end

  def create
    related_ids = producto_params[:related_product_ids]
    attrs = producto_params.except(:related_product_ids)
    @producto = Producto.new(attrs)
    # Force manual source for dashboard creations to avoid API-only validations
    @producto.source = :manual
    if @producto.save
      @producto.related_product_ids = related_ids if related_ids.present?
      redirect_to [:dashboard, @producto], notice: "Producto creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update


    if params[:producto][:imagenes].is_a?(Array) && params[:producto][:imagenes].all?(&:blank?)
    params[:producto].delete(:imagenes)
    end


    if params[:eliminar_imagenes]
      params[:eliminar_imagenes].each do |img_id|
        @producto.imagenes.find(img_id).purge
      end
    end
  
    related_ids = producto_params[:related_product_ids]
    attrs = producto_params.except(:related_product_ids)
    if @producto.update(attrs)
      @producto.related_product_ids = related_ids if related_ids.present?
      redirect_to [:dashboard, @producto], notice: "Producto actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @producto.destroy
    redirect_to dashboard_productos_url, notice: "Producto eliminado."
  end

  private

  def set_producto
    @producto = Producto.find(params[:id])
  end

  def producto_params
    params.require(:producto).permit(
      :external_id, :sku, :marca_id, :categoria_id, :subcategoria_id,
      :destacado, :mas_vendido,
      :descripcion, :especificaciones_tecnicas,
      imagenes: [],
      related_product_ids: []
    )
  end
end