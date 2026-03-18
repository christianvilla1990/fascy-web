class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Pagy::Backend
   before_action :cargar_categorias

  layout :layout_by_resource

  private

  def cargar_categorias
    @categorias = Categoria.includes(:subcategorias).order(:nombre)
  end
  
  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
  
  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      dashboard_root_path
    else
      super
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    new_admin_user_session_path
  end
  
end
