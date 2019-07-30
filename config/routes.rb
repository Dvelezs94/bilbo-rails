Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: "registrations" }
  devise_scope :user do
    root :to => 'devise/sessions#new'
  end
  resources :dashboards, only: [:index]
  resources :ads do
    member do
      post "add_multimedia"
    end
    resources :attachments, only:  [:create, :destroy]
  end
  resource :boards, only: :show do
    get 'get_info' => 'boards#get_info'
    member do
      get :owned
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
