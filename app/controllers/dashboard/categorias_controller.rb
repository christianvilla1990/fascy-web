class Dashboard::CategoriasController < Dashboard::BaseController
  before_action :set_categoria, only: %i[edit update]

  def index
    @categorias = Categoria.all
  end

  def edit
  end

  def update
    if @categoria.update(categoria_params)
      redirect_to dashboard_categorias_path, notice: 'Categoría actualizada correctamente.'
    else
      render :edit
    end
  end

  # GET /dashboard/categorias/:id/subcategorias
  def subcategorias
    subs = Subcategoria.where(categoria_id: params[:id]).order(:nombre).select(:id, :nombre)
    render json: subs
  end

  private

  def set_categoria
    @categoria = Categoria.find(params[:id])
  end

  def categoria_params
    params.require(:categoria).permit(:nombre, :principal, :prioridad, :imagen)
  end
end
