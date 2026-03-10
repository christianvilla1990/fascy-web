class AddDescripcionEspecificacionesToProducto < ActiveRecord::Migration[6.1]
  def change
    add_column :productos, :descripcion, :text
    add_column :productos, :especificaciones_tecnicas, :text
  end
end
