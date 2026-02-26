require 'httparty'

class ApiFify
  include HTTParty
  base_uri ENV.fetch('FIFY_BASE_URL', 'http://www.api.fify.com.py:96')
  default_timeout 10

  def initialize(user: ENV['FIFY_USER'] || 'tileria', password: ENV['FIFY_PASSWORD'] || '123456')
    @headers = {
      'accept' => '*/*',
      'User' => user,
      'Password' => password,
      'Content-Type' => 'application/json'
    }
  end

  def listar_productos(codigo_cliente:, product_id:)
    body = { codigo_cliente: codigo_cliente, product_id: product_id }.to_json
    self.class.post('/api/Producto/ListarProductos', headers: @headers, body: body).parsed_response
  end
end