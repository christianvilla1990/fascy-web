class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Pagy::Backend
   before_action :cargar_categorias

  private

  def cargar_categorias
    @categorias = Categoria.includes(:subcategorias).order(:nombre)
  end
  
end
