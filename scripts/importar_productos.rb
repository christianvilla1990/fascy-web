require_relative '../config/environment'

cantidad = ImportadorProductos.new.importar(codigo_cliente: 'string', product_id: '')
puts "Marcas importadas: #{cantidad}"