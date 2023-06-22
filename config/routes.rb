Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  constraints(Subdomain) do
    require "sidekiq/web"

    devise_for :users,
      skip: :registrations,
      controllers: {
        sessions: "users/sessions",
        invitations: "users/invitations"
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
      resources :users do
        post :invite, on: :member
      end
      resources :api_keys, only: [:create, :index, :show, :destroy]
      resources :source_files, only: [:index, :edit, :show, :update, :destroy] do
        resources :data_imports, except: [:index]
      end
      resources :occupation_standards, only: [:index, :show, :edit, :update]
      resources :work_processes, only: [:show, :edit, :update]
      resources :competencies, only: [:show, :edit, :update]
      resources :competency_options, only: [:show, :edit, :update]
      resources :wage_steps, only: [:show, :edit, :update]
      resources :contact_requests, only: [:index, :show]
    end
  end

  # SEO-friendly routes for Occupation Standards
  get ":state/occupation_standards",
    to: "occupation_standards#index",
    as: :occupation_standards_by_state,
    constraints: {state: /[a-zA-Z]{2}/}

  root to: "pages#home", as: :guest_root

  scope :occupation_standards do
    resources :national_standards, only: [:index]
  end
  resources :standards_imports, only: [:new, :create, :show]
  resources :occupation_standards, only: [:index, :show]
  resources :industries, only: [:index]
  resources :states, only: [:index]
  get "home", as: :home_page, to: "pages#home"
  get "about", as: :about_page, to: "pages#about"
  get "definitions", as: :definitions_page, to: "pages#definitions"
  get "terms", as: :terms_page, to: "pages#terms"
  get "contact", as: :contact_page, to: "contact_requests#new"
  resources :contact_requests, only: [:create]

  namespace :api do
    namespace :v1 do
      jsonapi_resources :occupations
      jsonapi_resources :standards
    end
  end
end
