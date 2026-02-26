class ProductosController < ApplicationController
    layout "admin"
    def new
    @producto = Producto.new
  end

  def create
    @producto = Producto.new(producto_params)
    if @producto.save
      redirect_to productos_path, notice: "Producto creado correctamente"
    else
      render :new
    end
  end

  def edit
    @producto = Producto.find(params[:id])
  end

  def update
    @producto = Producto.find(params[:id])
    if @producto.update(producto_params)
      redirect_to productos_path, notice: "Producto actualizado"
    else
      render :edit
    end
  end

  def index
    @productos = Producto.all
  end

  def show
    @producto = Producto.find(params[:id])
  end

  private

  def producto_params
    params.require(:producto).permit(
      :nombre,
      :descripcion,
      :precio,
      :destacado,
      :categoria_id,
      :subcategoria_id,
      :datos_tecnicos,
      :descripcion_uso,
       imagenes: [] # <-- permite múltiples imágenes
    )
  end
end
