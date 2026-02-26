class AddDatosTecnicosYDescripcionUsoToProductos < ActiveRecord::Migration[7.2]
  def change
    add_column :productos, :datos_tecnicos, :text
    add_column :productos, :descripcion_uso, :text
  end
end
