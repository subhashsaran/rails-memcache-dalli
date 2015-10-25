Store::Application.routes.draw do
  get "info/about"
  resources :products
  root to: 'products#index'
end
