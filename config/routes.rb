Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: "registrations" }
  devise_scope :user do
    root :to => 'devise/sessions#new'
  end
  resource :dashboards, only: :show
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
