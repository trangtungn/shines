Rails.application.routes.draw do
  devise_for :users
  # dashboard
  root 'dashboard#index'
  # creators
  resources :creators, only: [ :index, :show ]
end
