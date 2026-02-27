Rails.application.routes.draw do
  get "categorias/index"
  get "home/index"
  get "home/categoria/:id", to: "home#categoria", as: :home_categoria
  get "home/productos/:id", to: "home#productos_detalle", as: :home_productos_detalle
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest


  

    namespace :dashboard do
      root to: "productos#index"
      resources :productos
      resources :banners
      resources :categorias, only: [:index, :edit, :update]
    end


  # Defines the root path route ("/")
  root "home#index"
end
