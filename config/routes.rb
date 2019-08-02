Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: "registrations" }
  root :to => 'dashboards#index'
  resources :dashboards, only: [:index]
  resources :ads do
    resources :attachments, only:  [:create, :destroy]
  end
  resources :campaigns do
    member do
      get :analytics
    end
  end
  resources :boards, only: :index do
    collection do
      get :get_info
      get :owned
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
