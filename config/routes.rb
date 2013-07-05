T2Api::Application.routes.draw do

  # allows for the url in form of 'api.neo.com/v1/clients'
  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      resources :clients, only: [:index, :show, :create]
      resources :projects, only: [:index, :show, :update, :create, :destroy]
      resources :slots, only: [:index, :show]
      resources :allocations, only: [:index, :show, :update, :create, :destroy]
      resources :roles, only: [:index, :show]
      resources :people, only: [:index, :show]
      resources :offices, only: [:index, :show]
    end
  end
end
