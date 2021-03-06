T2Api::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_in', :to => 'sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'sessions#destroy', :as => :destroy_user_session
  end

  # allows for the url in form of 'api.neo.com/v1/clients'
  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      resource :navbar, only: [:show]
      resource :profile
      resources :skills, only: [:index]
      resources :projects, only: [:index, :show, :update, :create, :destroy]
      resources :allocations, only: [:index, :show, :update, :create, :destroy]
      resources :conflicts, only: [:index]
      resources :allocation_bundles, only: [:index]
      resources :people, only: [:index, :show, :update, :create] do
        resources :pto_requests, only: [:index, :create, :update, :destroy]

        member do
          get "profile"
          get "similar"
        end
      end
      resources :offices, only: [:index, :show]
      resources :snapshots, only: [:index, :show]
      resources :utilization_counts, only: :index
      resources :utilization_summaries, only: :index
      resources :monthly_snapshots, only: [:index, :show]
      resources :users, only: [:show, :update]
      resources :t2_applications, only: :index
      resources :availabilities, only: :index
      resources :daily_reports, only: [] do
        collection do
          get ":date" => :show
        end
      end
    end
  end

  resource :reports, only: [] do
    get :revenue
    get :staff
  end

  get "navbar" => "application#navbar"
  root to: "application#show"
end
