Rails.application.routes.draw do
  get "import_details/index"
  get "sign_ups/new"
  get "sign_ups/create"
  get "sessions/new"
  get "sessions/create"
  get "sessions/destroy"
  get "affiliates", to: "affiliates#index"
  get "merchants", to: "merchants#index"
  resources :imports, only: [ :create, :new, :index ] do
    get "details", to: "import_details#index", as: :import_details
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "imports#new"
  get "/sign_up", to: "sign_ups#new"
  post "/sign_up", to: "sign_ups#create"

  get "/sign_in", to: "sessions#new"
  post "/sign_in", to: "sessions#create"
  get "/logout", to: "sessions#destroy"

  root "sessions#new"
end
