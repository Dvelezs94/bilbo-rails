Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/api"
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
  post "/api", to: "graphql#execute"

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: "registrations", sessions: "sessions" }
  root :to => 'dashboards#index'
  resources :dashboards, only: [:index] do
    collection do
      get :provider_statistics
    end
  end
  resources :ads do
    resources :attachments, only:  [:create, :destroy, :update]
      member do
        get :modal_action
      end
  end
  resources :campaigns do
    member do
      get :analytics
      put :toggle_state
    end
    collection do
      get :provider_index
    end
    resources :boards, only: [], controller: :board_campaigns do
      put :approve_campaign
      put :deny_campaign
      put :in_review_campaign
    end
    resource :provider_invoices, only: :create
  end
  resources :boards, only: [:index, :show, :create] do
    collection do
      get :map_frame
      get :get_info
      get :owned
      get :admin_index
    end
    member do
      get :regenerate_access_token
      get :regenerate_api_token
      # statistics of a single board
      get :statistics
    end
  end
  resource :payment, only: [:new, :create] do
    member do
      post :express
    end
  end
  resources :invoices, only: [:index, :show]
  resources :provider_invoices, only: [:index]

  namespace :admin do
    resources :main, only: [:index]
    resources :users, only: [] do
      collection do
        get :index
      end
      member do
        get :fetch
        patch :verify
      end
    end
  end
  resources :searches, only:[] do
    collection do
      get :autocomplete_user_email
    end
  end
  resources :csv, controller: "csv", only: [] do
    collection do
      get :generate_provider_report
      get :validate_daily_generation
    end
  end
  resources :projects do
    resources :project_users, path: :users, module: :projects, only: [:create, :destroy]
    member do
      get :change_project
    end
  end

  resources :charts, only: [] do
    member do
      get :daily_impressions
      get :daily_invested
      get :peak_hours
      get :daily_earnings
      get :campaign_of_day
      get :impressions_count
      get :top_campaigns
    end
  end

  resource :verification
  resources :notifications, only: [:index] do
    collection do
      get :clear
    end
  end
  resources :impressions, only: [:index] do
    collection do
      get :fetch
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
