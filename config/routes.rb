T2Api::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_in', :to => 'sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  # allows for the url in form of 'api.neo.com/v1/clients'
  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      resource :navbar, only: [:show]
      resource :profile
      resources :skills, only: [:index]
      resources :projects, only: [:index, :show, :update, :create, :destroy]
      resources :slots, only: [:index, :show]
      resources :allocations, only: [:index, :show, :update, :create, :destroy]
      resources :people, only: [:index, :show] do
        resources :pto_requests, only: [:index, :create, :update, :destroy]

        member do
          get "profile"
        end
      end
      resources :offices, only: [:index, :show]
      resources :snapshots, only: [:index, :show]
      resources :monthly_snapshots, only: [:index, :show]
      resources :users, only: [:show, :update]
      resources :t2_applications, only: :index
      resources :daily_reports, only: [] do
        collection do
          get ":date" => :show
        end
      end
    end
  end

  match "navbar" => "application#navbar"
  root to: "application#show"
end
