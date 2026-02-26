class AddEstadoToProductos < ActiveRecord::Migration[7.2]
  def change
    
    add_column :productos, :destacado,   :boolean, null: false, default: false
    add_column :productos, :mas_vendido, :boolean, null: false, default: false
    add_index  :productos, :destacado
    add_index  :productos, :mas_vendido

  end
end
