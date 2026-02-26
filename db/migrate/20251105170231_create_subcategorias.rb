class CreateSubcategorias < ActiveRecord::Migration[7.2]
  def change
    create_table :subcategorias do |t|
      t.string :nombre
      t.string :external_id

         t.references :categoria, null: false, foreign_key: true

      t.timestamps
    end
  end
end
