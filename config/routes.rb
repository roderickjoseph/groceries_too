Rails.application.routes.draw do
  devise_for :users
  root 'lists#index'
  resources :lists
end
