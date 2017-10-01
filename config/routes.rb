Rails.application.routes.draw do
  devise_for :users
  root 'lists#index'
  resources :lists do
    resources :items, only: %i[new create edit update show]
  end

end
