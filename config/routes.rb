Rails.application.routes.draw do
  require 'sidekiq/web'

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/api"
  end
#Show error custom pages only in production
  if Rails.env.production? || Rails.env.staging? || Rails.env.demo?
    get '/500', to: "error#internal_error"
    get '/404', to: "error#not_found"
  end

  # allow sidekiq access only to admin
  authenticated :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
    mount Blazer::Engine, at: "blazer"
  end

  post "/api", to: "graphql#execute"
  mount Bilbo::API => '/'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: "registrations", sessions: "sessions", invitations: "users/invitations" }
  root :to => 'dashboards#index'
  resources :dashboards, only: [:index] do
    collection do
      get :provider_statistics
      get :monthly_statistics
    end
  end

  resources :contents do
    member do
      get :contents_modal_review
    end
    collection do
      get :new_multimedia
      get :new_url
      get :create_content_on_campaign
      post :create_multimedia
      post :create_url
    end
  end

  resources :contents_board_campaign do
    collection do
      get :get_contents_wizard_modal
      get :get_selected_content
      get :get_summary_info
    end
    member do
      get :fetch_single_wizard_content
    end
  end

  resources :board_default_contents do
    collection do
      get :edit_default_content
      get :contents_board_modal
      get :get_selected_default_contents
      get :create_or_update_default_content
      get :get_default_contents
    end
  end

  resources :map_photos do
    collection do
      get :new_image
      post :create_multimedia
    end
  end

  resources :board_map_photos do
    collection do
      get :edit_board_images
      get :images_board_modal
      get :images_new_board_modal
      get :get_selected_map_photos
      get :create_or_update_board_map_photos
    end
    member do
      get :fetch_single_map_photo
    end
  end

  resources :map_photos do
    collection do
      get :new_image
      post :create_multimedia
    end
  end

  resources :board_map_photos do
    collection do
      get :edit_board_images
      get :images_board_modal
      get :get_selected_map_photos
      get :create_or_update_board_map_photos
    end
    member do
      get :fetch_single_map_photo
    end
  end

  resources :witnesses, only: [:show, :create, :edit, :update] do
    member do
      get  :evidences_witness_modal
      get  :evidences_dashboard_provider
    end
  end

  resources :evidences, only: [:update] do
    member do
      get :new_evidence
    end
  end

  resources :campaigns do
    member do
      get :get_boards_content_info
    end
    resources :campaign_subscribers, path: "subscribers", as: :subscribers, except: [:edit] do
      collection do
        get :edit
      end
    end
    member do
      get :analytics
      get :redirect_to_external_link
      put :toggle_state
      get :wizard_fetch
      get :get_content
      get :fetch_campaign_details
      get :get_used_contents
      get :download_qr_instructions
      get :copy_campaign
      post :create_copy
    end
    collection do
      get :provider_index
    end
    resources :boards, only: [], controller: :board_campaigns do
      put :approve_campaign
      put :deny_campaign
      put :in_review_campaign
      get :show
    end

    resource :provider_invoices, only: :create
  end

  post '/board_campaigns/multiple_update', to: 'board_campaigns#multiple_update'
  post '/board_campaigns/get_denied_board_campaigns', to: 'board_campaigns#get_denied_board_campaigns'

  resources :boards, only: [:index, :show, :create, :edit, :update] do
    collection do
      get :map_frame
      get :get_info
      get :owned
      get :admin_index
    end
    member do
      post :requestAdsRotation
      get :loading
      post :update
      delete :delete_image
      delete :delete_default_image
      get :regenerate_access_token
      get :regenerate_api_token
      # statistics of a single board
      get :statistics
      get :toggle_status
      get :reload_board
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
    resources :main, only: [:index] do
      collection do
        get :web_console
      end
    end
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
        get :sync_sendgrid_contacts
      end
      member do
        post :toggle_ban
        put :update_credit
        put :increase_credits
        get :fetch
        patch :verify
        patch :deny
        post :toggle_show_recent_campaigns
        post :impersonate
      end
    end
    resources :projects do
      collection do
        get :index
      end
      member do
        put :update_permissions
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
    resources :sales
  end
  resources :searches, only:[] do
    collection do
      get :autocomplete_user_email
      get :autocomplete_board_name
      get :autocomplete_establishment_list
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
      get :daily_qr_code_scans
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

  resources :dashboard_players, only: [:index, :create, :destroy, :update] do
    collection do
      delete :delete_player
    end
  end

  # resources :landing_pages, as: 'landings' do
  #   member do
  #     #get :landing, controller: "landing_pages#show_board"
  #   end
  # end

  get 'c/:id', to: "campaigns#shortened_analytics", as: "campaign_shortened"
  get 's/:id', to: "shorteners#show", as: "shorten"

  get '/pantallas/:state/:city/:name', to: 'landing_pages#show', as: 'bilbo_landing'
  get '/sitemap', to: 'pages#sitemap'
  get '/robots.:format', to: 'pages#robots'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
