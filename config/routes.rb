Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: "registrations" }
  root :to => 'dashboards#index'
  resources :dashboards, only: [:index] do
    collection do
      get :provider_statistics
    end
  end
  resources :ads do
    resources :attachments, only:  [:create, :destroy]
  end
  resources :campaigns do
    member do
      get :analytics
      put :toggle_state
    end
  end
  resources :boards, only: [:index, :show, :create] do
    collection do
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
  resources :admins, only: [:index], as: "admin" do
    collection do
      get :show_users
    end
  end
  resources :searches, only:[] do
    collection do
      get :autocomplete_user_email
    end
  end
  resources :notifications
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
