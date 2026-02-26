class CreateProductos < ActiveRecord::Migration[7.2]
  def change
    create_table :productos do |t|
      t.string :external_id
      t.string :string
      t.string :caracteristica
      t.string :sku
      t.string :price
      t.string :decimal12
      t.string :decimal2
      t.string :data
      t.string :jsonb
      t.references :marca, null: false, foreign_key: true
      t.references :categoria, null: false, foreign_key: true
      t.references :subcategoria, null: false, foreign_key: true

      t.timestamps
    end
  end
end
