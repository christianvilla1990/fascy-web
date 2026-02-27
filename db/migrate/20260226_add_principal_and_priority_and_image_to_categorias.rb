class AddPrincipalAndPriorityAndImageToCategorias < ActiveRecord::Migration[6.1]
  def change
    add_column :categorias, :principal, :boolean, default: false
    add_column :categorias, :prioridad, :integer, default: 0
  end
end
