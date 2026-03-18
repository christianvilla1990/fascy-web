class Dashboard::ImportsController < Dashboard::BaseController
  # POST /dashboard/import_products
  def create
    # Execute: run the CLI importer that persists changes
    codigo_cliente = params[:codigo_cliente].presence || ENV['IMPORT_CLIENT_CODE'] || 'string'
    product_id     = params[:product_id].presence || ''
    marca_filtro   = params[:marca_filtro].presence || ENV['IMPORT_BRAND_FILTER'] || 'FASCY'

    result = ImportadorProductos.new.importar(codigo_cliente: codigo_cliente, product_id: product_id, marca_filtro: marca_filtro)

    notice = "Import finished: creados=#{result[:creados]} actualizados=#{result[:actualizados]} (marca_filtro=#{marca_filtro})"
    redirect_to dashboard_root_path, notice: notice
  rescue => e
    redirect_to dashboard_root_path, alert: "Import failed: #{e.message}"
  end
end
