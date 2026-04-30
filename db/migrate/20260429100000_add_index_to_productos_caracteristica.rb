class AddIndexToProductosCaracteristica < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :productos, :caracteristica,
              name: "index_productos_on_caracteristica",
              algorithm: :concurrently,
              if_not_exists: true
  end
end
