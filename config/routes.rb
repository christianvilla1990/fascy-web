Rails.application.routes.draw do
  devise_for :admin_users
  get "categorias/index"
  get "home/index"

  # SEO-friendly canonical URLs (con slug)
  get "categoria/:id", to: "home#categoria", as: :home_categoria
  get "producto/:id",  to: "home#productos_detalle", as: :home_productos_detalle

  # 301 redirects desde URLs antiguas hacia las nuevas (compatibilidad)
  get "home/categoria/:id", to: redirect("/categoria/%{id}", status: 301)
  get "home/productos/:id", to: redirect("/producto/%{id}",  status: 301)

  get "home/buscar_productos", to: "home#buscar_productos", as: :home_buscar_productos
  get "sitemap.xml",           to: "home#sitemap",          as: :sitemap, defaults: { format: "xml" }
  get "sobre-nosotros",        to: "home#sobre_nosotros",   as: :sobre_nosotros
  get "sucursales",            to: "home#sucursales",       as: :sucursales
  get  "contacto",             to: "home#contacto",         as: :contacto
  post "contacto",             to: "home#enviar_contacto",  as: :enviar_contacto

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest"       => "rails/pwa#manifest",       as: :pwa_manifest

  namespace :dashboard do
    root to: "home#index"
    resources :productos
    resources :banners
    resources :categorias, only: [:index, :edit, :update]
    get 'categorias/:id/subcategorias', to: 'categorias#subcategorias', as: 'categoria_subcategorias'
    post 'import_products', to: 'imports#create', as: 'import_products'
  end

  resources :newsletter_subscriptions, only: [:create]

  # Root
  root "home#index"
end
