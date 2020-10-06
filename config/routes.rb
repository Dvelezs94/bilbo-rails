Rails.application.routes.draw do
  require 'sidekiq/web'
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/api"
  end
#Show error custom pages only in production
  if Rails.env.production? || Rails.env.staging?
    get '/500', to: "error#internal_error"
    get '/404', to: "error#not_found"
  end

  # allow sidekiq access only to admin
  authenticated :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
    mount Blazer::Engine, at: "blazer"
  end

  post "/api", to: "graphql#execute"

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: "registrations", sessions: "sessions", invitations: "users/invitations" }
  root :to => 'dashboards#index'
  resources :dashboards, only: [:index] do
    collection do
      get :provider_statistics
      get :monthly_statistics
    end
  end

  resources :ads do
    resources :attachments, only:  [:create, :destroy, :update]
      member do
        get :modal_action
      end
      collection do
        get :wizard_fetch
      end
  end
  resources :campaigns do
    resources :campaign_subscribers, path: "subscribers", as: :subscribers, except: [:edit] do
      collection do
        get :edit
      end
    end
    member do
      get :analytics
      put :toggle_state
      get :wizard_fetch
      get :getAds
      get :get_used_boards
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
  resources :boards, only: [:index, :show, :create, :edit,:update] do
    collection do
      get :map_frame
      get :get_info
      get :owned
      get :admin_index
    end
    member do
      delete :delete_image
      get :regenerate_access_token
      get :regenerate_api_token
      # statistics of a single board
      get :statistics
      get :toggle_status
    end
  end
  resources :payments, only: [:new, :create] do
    collection do
      post :express
      post :create_spei
      get :generate_sheet
    end
    member do
      delete :cancel_spei
      get :check_payment
      post :update_reference
    end
  end
  resources :invoices, only: [:index, :show]
  resources :provider_invoices, only: [:index]

  namespace :admin do
    resources :main, only: [:index]
    resources :board_actions, only: [] do
      member do
        get :provider_statistics
        get :get_ads_rotation_build
        post :regenerate_ads_rotation
      end
    end
    resources :users, only: [] do
      collection do
        get :index
        get :stop_impersonating
      end
      member do
        post :toggle_ban
        put :update_credit
        put :increase_credits
        get :fetch
        patch :verify
        patch :deny
        post :impersonate
      end
    end
    resources :payments, only: [] do
      collection do
        get :index
      end
      member do
        post :approve
        post :deny
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
      get :generate_campaign_report
      get :generate_campaign_provider_report
      get :generate_board_provider_report
      get :validate_daily_generation
      get :download_csv
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

  resource :external_sources, only: [:setup] do
    member do
      get :setup
      post :configure
    end
  end

  get 'c/:id', to: "campaigns#shortened_analytics", as: "campaign_shortened"
  get 's/:id', to: "shorteners#show", as: "shorten"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
