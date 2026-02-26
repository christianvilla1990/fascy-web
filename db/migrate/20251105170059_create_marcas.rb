class CreateMarcas < ActiveRecord::Migration[7.2]
  def change
    create_table :marcas do |t|
      t.string :nombre
      t.string :external_id

      t.timestamps
    end
  end
end
