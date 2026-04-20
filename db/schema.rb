# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_04_20_145600) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "banners", force: :cascade do |t|
    t.string "titulo"
    t.text "descripcion"
    t.string "tipo"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categorias", force: :cascade do |t|
    t.string "nombre"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "principal", default: false
    t.integer "prioridad", default: 0
    t.string "slug"
    t.index ["slug"], name: "index_categorias_on_slug", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "marcas", force: :cascade do |t|
    t.string "nombre"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "newsletter_subscriptions", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_newsletter_subscriptions_on_email", unique: true
  end

  create_table "productos", force: :cascade do |t|
    t.string "external_id"
    t.string "string"
    t.string "caracteristica"
    t.string "sku"
    t.string "price"
    t.string "decimal12"
    t.string "decimal2"
    t.string "data"
    t.string "jsonb"
    t.bigint "marca_id", null: false
    t.bigint "categoria_id", null: false
    t.bigint "subcategoria_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "datos_tecnicos"
    t.text "descripcion_uso"
    t.integer "source", default: 0, null: false
    t.boolean "destacado", default: false, null: false
    t.boolean "mas_vendido", default: false, null: false
    t.text "descripcion"
    t.text "especificaciones_tecnicas"
    t.string "slug"
    t.index ["caracteristica"], name: "index_productos_on_caracteristica_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["categoria_id"], name: "index_productos_on_categoria_id"
    t.index ["destacado"], name: "index_productos_on_destacado"
    t.index ["marca_id"], name: "index_productos_on_marca_id"
    t.index ["mas_vendido"], name: "index_productos_on_mas_vendido"
    t.index ["slug"], name: "index_productos_on_slug", unique: true
    t.index ["source"], name: "index_productos_on_source"
    t.index ["subcategoria_id"], name: "index_productos_on_subcategoria_id"
  end

  create_table "related_products", force: :cascade do |t|
    t.bigint "producto_id", null: false
    t.bigint "related_producto_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["producto_id", "related_producto_id"], name: "index_related_on_producto_and_related", unique: true
    t.index ["related_producto_id"], name: "index_related_products_on_related_producto_id"
  end

  create_table "subcategorias", force: :cascade do |t|
    t.string "nombre"
    t.string "external_id"
    t.bigint "categoria_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["categoria_id"], name: "index_subcategorias_on_categoria_id"
    t.index ["slug"], name: "index_subcategorias_on_slug", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "productos", "categorias"
  add_foreign_key "productos", "marcas"
  add_foreign_key "productos", "subcategorias"
  add_foreign_key "subcategorias", "categorias"
end
