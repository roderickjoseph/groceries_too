Rails.application.routes.draw do
  devise_for :users
  root 'lists#index'
  resources :lists do
    resources :items, only: :create
  end

end
