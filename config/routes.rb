Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  constraints(Subdomain) do
    require "sidekiq/web"

    devise_for :users,
      skip: :registrations,
      controllers: {
        sessions: "users/sessions"
      }
    as :user do
      get "users/edit", to: "devise/registrations#edit", as: "edit_user_registration"
      patch "users", to: "devise/registrations#update", as: "user_registration"
      put "users", to: "devise/registrations#update", as: nil
    end

    devise_scope :user do
      unauthenticated do
        root to: "users/sessions#new", as: :unauthenticated_root
      end

      authenticated :user do
        root to: "admin/source_files#index"
        mount Sidekiq::Web => "/sidekiq", :as => :sidekiq
      end
    end

    namespace :admin do
      resources :data_imports, except: [:index]
      resources :users
      resources :api_keys, only: [:create, :index, :show, :destroy]
      resources :source_files, only: [:index, :edit, :show, :update, :destroy] do
        resources :data_imports, except: [:index]
      end
      resources :occupation_standards, only: [:index, :show, :edit, :update]
    end
  end

  root to: "pages#home", as: :guest_root

  scope :occupation_standards do
    resources :national_standards, only: [:index]
  end
  resources :standards_imports, only: [:new, :create, :show]
  resources :occupation_standards, only: [:index, :show]
  get "home", as: :home_page, to: "pages#home"
  get "about", as: :about_page, to: "pages#about"
  get "definitions", as: :definitions_page, to: "pages#definitions"

  namespace :api do
    namespace :v1 do
      jsonapi_resources :occupations
      jsonapi_resources :standards
    end
  end
end
