Rails.application.routes.draw do
  devise_for :users
  root 'lists#index'
  # resources :lists
  resources :lists do
    resources :items, shallow: true
  end

end
