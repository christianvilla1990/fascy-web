class CreateSiteSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :site_settings do |t|
      t.string :nombre_sitio
      t.timestamps
    end
  end
end
