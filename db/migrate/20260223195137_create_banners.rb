class CreateBanners < ActiveRecord::Migration[7.2]
  def change
    create_table :banners do |t|
      t.string :titulo
      t.text :descripcion
      t.string :tipo
      t.string :link

      t.timestamps
    end
  end
end
