class AddSlugsToResources < ActiveRecord::Migration[7.2]
  def change
    add_column :categorias, :slug, :string
    add_index  :categorias, :slug, unique: true

    add_column :subcategorias, :slug, :string
    add_index  :subcategorias, :slug, unique: true

    add_column :productos, :slug, :string
    add_index  :productos, :slug, unique: true
  end
end
