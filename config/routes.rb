Rails.application.routes.draw do
  root "home#index"

  devise_for :admins, controllers: {
    registrations: "admin/registrations"
  }

  authenticate :admin do
    root to: "admin#index", as: :admin_root
  end

  namespace :admin do
    resources :orders
    resources :categories
    resources :products do
      resources :stocks
    end
  end

  resources :categories, only: [ :show ]     

  get "admin" => "admin#index"
  get "cart" => "cart#show"
  get "precios", to: "prices#index"

  
  post "webhooks/mercadopago" => 'webhooks#mercadopago'
  
  post '/checkout', to: 'checkouts#create'
  get '/checkout/success', to: 'checkouts#success'
  get '/checkout/failure', to: 'checkouts#failure'  
  get '/checkout/pending', to: 'checkouts#pending'

  resources :products, only: [ :show ]
  resources :templates
end
