class HomeController < ApplicationController
  def buscar_productos
    query = params[:search].to_s.strip
    @categoria = nil
    @subcategoria = nil
    @search_term = query
    @sort = sanitize_sort(params[:sort])

    base = if query.length >= 2
             Producto.with_attached_imagenes
                     .includes(:marca)
                     .where("caracteristica ILIKE ?", "%#{query}%")
           else
             Producto.none
           end

    @section_title = query.present? ? "Resultados para \"#{query}\"" : "Búsqueda"
    @pagy, @productos = pagy(apply_sort(base, @sort), items: 24)
    @total_count = @pagy.count
    render :categoria
  end
  def index
    @titulo = "Bienvenido a Fascy Web"
    # Solo categorías con productos destacados
    @categorias_destacadas = Categoria.joins(:productos).merge(Producto.destacados).distinct.order(:nombre)
    @productos_promo_mes = Producto.where(mas_vendido: true)
    @banners_principales = Banner.where(tipo: "principal").order(created_at: :desc)
    @banners_secundarios = Banner.where(tipo: "secundario").order(created_at: :desc)

    productos_scope = Producto.with_attached_imagenes.destacados
    if params[:categoria].present?
      @productos_destacados = productos_scope.where(categoria_id: params[:categoria])
    else
      @productos_destacados = productos_scope
    end

    respond_to do |format|
      format.html
      format.turbo_stream { render partial: "home/productos_destacados", locals: { productos: @productos_destacados } }
    end
  end

  def categoria
    productos_scope = Producto.with_attached_imagenes.includes(:marca)
    @categoria    = nil
    @subcategoria = nil
    @sort = sanitize_sort(params[:sort])
    @q_refine = params[:q_refine].to_s.strip

    if params[:id] == 'destacados'
      base = productos_scope.destacados
      @section_title = 'Productos destacados'
    elsif params[:id] == 'promo_mes'
      base = productos_scope.where(mas_vendido: true)
      @section_title = 'Promo del Mes'
    elsif (@categoria = find_friendly(Categoria, params[:id]))
      redirect_to(home_categoria_path(@categoria), status: :moved_permanently) and return if request.path != home_categoria_path(@categoria)

      @subcategorias_filtro = @categoria.subcategorias.order(:nombre).load
      subcategorias_ids = @subcategorias_filtro.map(&:id)
      base = productos_scope.where(subcategoria_id: subcategorias_ids)
      @section_title = @categoria.nombre

      if params[:sub].present?
        @subcategoria_actual = @subcategorias_filtro.detect { |s| s.slug == params[:sub] || s.id.to_s == params[:sub].to_s }
        base = base.where(subcategoria_id: @subcategoria_actual.id) if @subcategoria_actual
      end
    elsif (@subcategoria = find_friendly(Subcategoria, params[:id]))
      redirect_to(home_categoria_path(@subcategoria), status: :moved_permanently) and return if request.path != home_categoria_path(@subcategoria)

      base = productos_scope.where(subcategoria_id: @subcategoria.id)
      @section_title = @subcategoria.nombre
    else
      base = Producto.none
      @section_title = 'Sin resultados'
    end

    if @q_refine.length >= 2
      base = base.where("caracteristica ILIKE ?", "%#{@q_refine}%")
    end

    @pagy, @productos = pagy(apply_sort(base, @sort), items: 24)
    @total_count = @pagy.count
    render layout: false if turbo_frame_request?
  end

  def productos_detalle
    @producto = Producto.with_attached_imagenes.friendly.find(params[:id])

    if request.path != home_productos_detalle_path(@producto)
      redirect_to(home_productos_detalle_path(@producto), status: :moved_permanently) and return
    end

    render layout: false if turbo_frame_request?
  rescue ActiveRecord::RecordNotFound
    raise
  end

  private

  # Devuelve el registro o nil (no raise). Si el id es numérico y no existe, devuelve nil.
  def find_friendly(klass, id)
    klass.friendly.find(id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  ALLOWED_SORTS = %w[name_asc name_desc recent].freeze

  def sanitize_sort(value)
    s = value.to_s
    ALLOWED_SORTS.include?(s) ? s : 'name_asc'
  end

  def apply_sort(scope, sort)
    case sort
    when 'name_desc' then scope.order(caracteristica: :desc)
    when 'recent'    then scope.order(updated_at: :desc)
    else                  scope.order(:caracteristica)
    end
  end

  public

  def sobre_nosotros
  end

  def sitemap
    @categorias = Categoria.includes(:subcategorias).order(:nombre)
    @productos  = Producto.order(updated_at: :desc).limit(5000)
    respond_to do |format|
      format.xml { render layout: false }
    end
  end

  def contacto
    @contacto = { nombre: "", email: "", telefono: "", asunto: "", mensaje: "" }
  end

  def enviar_contacto
    @contacto = {
      nombre: params[:nombre].to_s.strip,
      email: params[:email].to_s.strip,
      telefono: params[:telefono].to_s.strip,
      asunto: params[:asunto].to_s.strip,
      mensaje: params[:mensaje].to_s.strip
    }

    errores = []
    errores << "El nombre es obligatorio."  if @contacto[:nombre].blank?
    errores << "El email es obligatorio."   if @contacto[:email].blank?
    errores << "El email no es válido."     if @contacto[:email].present? && !(@contacto[:email] =~ URI::MailTo::EMAIL_REGEXP)
    errores << "El mensaje es obligatorio." if @contacto[:mensaje].blank?
    errores << "El mensaje es demasiado corto." if @contacto[:mensaje].present? && @contacto[:mensaje].length < 10

    if errores.any?
      flash.now[:contacto_error] = errores.join(" ")
      render :contacto, status: :unprocessable_entity
    else
      Rails.logger.info("[Contacto] #{@contacto.inspect}")
      redirect_to contacto_path, notice: "¡Gracias #{@contacto[:nombre]}! Tu mensaje fue enviado, te responderemos a la brevedad."
    end
  end

  def sucursales
    @sucursales = [
      {
        nombre: "Sucursal Central",
        direccion: "Av. Mariscal López 1234, Asunción",
        telefono: "(021) 209 123",
        whatsapp: "595981123456",
        email: "central@fascy.com.py",
        horario_semana: "Lunes a Viernes: 8:00 – 19:00",
        horario_finde: "Sábados: 8:00 – 13:00",
        destacada: true,
        map_embed: "https://www.google.com/maps?q=Asunci%C3%B3n%2C+Paraguay&output=embed"
      },
      {
        nombre: "Sucursal Shopping",
        direccion: "Av. San Martín 890, Asunción",
        telefono: "(021) 555 4321",
        whatsapp: "595981123457",
        email: "shopping@fascy.com.py",
        horario_semana: "Lunes a Domingo: 10:00 – 22:00",
        horario_finde: nil,
        destacada: false,
        map_embed: "https://www.google.com/maps?q=Shopping+Asunci%C3%B3n&output=embed"
      },
      {
        nombre: "Sucursal Ciudad del Este",
        direccion: "Av. Monseñor Rodríguez 555, Ciudad del Este",
        telefono: "(061) 220 456",
        whatsapp: "595981123458",
        email: "cde@fascy.com.py",
        horario_semana: "Lunes a Viernes: 8:00 – 18:00",
        horario_finde: "Sábados: 8:00 – 12:00",
        destacada: false,
        map_embed: "https://www.google.com/maps?q=Ciudad+del+Este%2C+Paraguay&output=embed"
      }
    ]
  end

end
