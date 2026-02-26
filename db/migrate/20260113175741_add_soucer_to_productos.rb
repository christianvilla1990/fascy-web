class AddSoucerToProductos < ActiveRecord::Migration[7.2]
  def change
    add_column :productos, :source, :integer, null: false, default: 0  # 0=manual, 1=api
    add_index :productos, :source
  end
end
