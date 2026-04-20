class AddTrigramIndexToProductosCaracteristica < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    enable_extension :pg_trgm unless extension_enabled?(:pg_trgm)

    unless index_exists?(:productos, :caracteristica, name: "index_productos_on_caracteristica_trgm")
      execute <<~SQL
        CREATE INDEX CONCURRENTLY IF NOT EXISTS index_productos_on_caracteristica_trgm
        ON productos
        USING gin (caracteristica gin_trgm_ops);
      SQL
    end
  end

  def down
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_productos_on_caracteristica_trgm;"
  end
end
