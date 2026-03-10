class CreateRelatedProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :related_products do |t|
      t.bigint :producto_id, null: false
      t.bigint :related_producto_id, null: false

      t.timestamps
    end

    add_index :related_products, [:producto_id, :related_producto_id], unique: true, name: 'index_related_on_producto_and_related'
    add_index :related_products, :related_producto_id

    # Optionally add foreign keys if you want DB-level constraints
    # add_foreign_key :related_products, :productos, column: :producto_id
    # add_foreign_key :related_products, :productos, column: :related_producto_id
  end
end
