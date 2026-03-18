require 'json'

class ImportadorProductos
  def initialize(client = ApiFify.new)
    @client = client
  end

  # Alias para que el script actual funcione
  def importar(codigo_cliente: 'string', product_id: '', marca_filtro: nil)
    importar_productos(codigo_cliente: codigo_cliente, product_id: product_id, marca_filtro: marca_filtro)
  end

  # 1) Importa/actualiza productos y asigna marca/categoría/subcategoría
  def importar_productos(codigo_cliente: 'string', product_id: '',marca_filtro: nil)
    resp  = @client.listar_productos(codigo_cliente: codigo_cliente, product_id: product_id)
    items = resp.is_a?(Hash) ? resp['data'] : (resp.is_a?(Array) ? resp : [])
    return { creados: 0, actualizados: 0 } unless items&.any?

    # Filtrar por marca (solo FASCY)
    if marca_filtro.present?
      filtro_norm = normalizar(marca_filtro)
      items.select! { |it| normalizar(it['marca']).casecmp(filtro_norm).zero? }
      return { creados: 0, actualizados: 0 } if items.empty?
    end
# ...existing code..


    campo_marca     = Marca.column_names.include?('nombre') ? :nombre : :name
    campo_categoria = Categoria.column_names.include?('nombre') ? :nombre : :name
    campo_subcat    = Subcategoria.column_names.include?('nombre') ? :nombre : :name

    marcas_cache     = {}
    categorias_cache = {}
    subcats_cache    = {}

    creados = 0
    actualizados = 0

    items.each do |i|
      # Resolver taxonomías
      marca = nil
      if (mn = normalizar(i['marca'])).present?
        marca = (marcas_cache[mn] ||= (Marca.find_or_create_by(campo_marca => mn) rescue Marca.find_by(campo_marca => mn)))
      
      end

      categoria = nil
      if (cn = normalizar(i['categoria'])).present?
        categoria = (categorias_cache[cn] ||= (Categoria.find_or_create_by(campo_categoria => cn) rescue Categoria.find_by(campo_categoria => cn)))
      end

      subcategoria = nil
      if categoria && (sn = normalizar(i['subcategoria'])).present? && sn.casecmp('VACIO') != 0
        key = [categoria.id, sn.downcase]
        subcategoria = (subcats_cache[key] ||= begin
          rec = Subcategoria.find_or_initialize_by(campo_subcat => sn, categoria_id: categoria.id)
          rec.categoria ||= categoria
          rec.save! if rec.new_record?
          rec
        rescue ActiveRecord::RecordNotUnique
          Subcategoria.find_by(campo_subcat => sn, categoria_id: categoria.id)
        end)
      end

      # Upsert producto
      cod_externo = i['codProducto']&.to_s
      raise 'Sin codProducto' if cod_externo.blank?

      cols = Producto.column_names
      producto =
        if cols.include?('external_id')
          Producto.find_or_initialize_by(external_id: cod_externo)
        elsif cols.include?('codigo_barra') && i['codigoBarra'].present?
          Producto.find_or_initialize_by(codigo_barra: i['codigoBarra'])
        else
          Producto.find_or_initialize_by(id: cod_externo.to_i)
        end

      was_new = producto.new_record?

      nombre = i['caracteristicas'].to_s.strip

      if was_new
        producto.caracteristica = (nombre.present? ? nombre : "Producto #{cod_externo}") if producto.has_attribute?('nombre')
        producto.name   = (nombre.present? ? nombre : "Producto #{cod_externo}") if producto.has_attribute?('name')
        producto.caracteristica = i['caracteristicas'].to_s.strip if producto.has_attribute?('caracteristica')

        if producto.has_attribute?('codigo_barra') && i['codigoBarra'].present?
          producto.codigo_barra = i['codigoBarra']
        elsif producto.has_attribute?('sku') && i['codigoBarra'].present?
          producto.sku = i['codigoBarra']
        end

        if i.key?('precio')
          producto.precio = i['precio'].to_f if producto.has_attribute?('precio')
          producto.price  = i['precio'].to_f if producto.has_attribute?('price')
        end

        producto.medida = i['medida'] if producto.has_attribute?('medida') && i['medida'].present?
        if producto.has_attribute?('enlinea')
          v = i['enlinea']
          producto.enlinea = (v.to_s == '1' || v.to_s.downcase == 'true')
        end

        producto.data = i if producto.respond_to?(:data=)

        producto.marca        = marca        if producto.has_attribute?('marca_id')
        producto.categoria    = categoria    if producto.has_attribute?('categoria_id')
        producto.subcategoria = subcategoria if producto.has_attribute?('subcategoria_id')
      else
        # On updates: only bring sku, caracteristica, marca, categoria and descripcion
        if producto.has_attribute?('codigo_barra') && i['codigoBarra'].present?
          producto.codigo_barra = i['codigoBarra']
        elsif producto.has_attribute?('sku') && i['codigoBarra'].present?
          producto.sku = i['codigoBarra']
        end

        producto.caracteristica = (nombre.present? ? nombre : producto.caracteristica) if producto.has_attribute?('caracteristica')

        producto.marca     = marca     if producto.has_attribute?('marca_id')
        producto.categoria = categoria if producto.has_attribute?('categoria_id')
        producto.subcategoria = subcategoria if producto.has_attribute?('subcategoria_id')

        # Only set descripcion/especificaciones_tecnicas if they are blank (preserve existing manual data)
        if producto.has_attribute?('descripcion')
          producto.descripcion = i['descripcion'] if producto.descripcion.blank? && i.key?('descripcion') && i['descripcion'].present?
        end
        if producto.has_attribute?('especificaciones_tecnicas')
          producto.especificaciones_tecnicas = i['especificaciones_tecnicas'] if producto.especificaciones_tecnicas.blank? && i.key?('especificaciones_tecnicas') && i['especificaciones_tecnicas'].present?
        end
        # Do NOT touch images/attachments on update
      end

      producto.save!
      was_new ? creados += 1 : actualizados += 1
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.warn("No se guardó codProducto=#{i['codProducto']}: #{e.record.errors.full_messages.join(', ')}")
    rescue => e
      Rails.logger.warn("Error codProducto=#{i['codProducto']}: #{e.class} #{e.message}")
    end

    { creados: creados, actualizados: actualizados }
  end

  

  private

  def normalizar(v)
    v.to_s.strip.gsub(/\s+/, ' ')
  end
end