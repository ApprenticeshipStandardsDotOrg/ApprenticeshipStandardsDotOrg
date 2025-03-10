Rails.application.routes.draw do
  get "cookies/create"
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
        root to: "admin/imports#index"
        mount Sidekiq::Web => "/sidekiq", :as => :sidekiq
      end
    end

    namespace :admin do
      resources :data_imports, except: [:index]
      resources :standards_imports
      resources :imports do
        resource :redact_file, only: [:new, :create]
        resources :data_imports, except: [:index]
        delete :redacted_import, on: :member, action: :destroy_redacted_pdf
        post :convert_with_ai, on: :member
      end
      resources :occupation_standards, only: [:index, :show, :edit, :update, :new, :create]
      resources :occupations, only: [:index, :show, :edit, :update]
      resources :organizations, only: [:index, :show, :edit, :update]
      resources :work_processes, only: [:show, :edit, :update]
      resources :competencies, only: [:show, :edit, :update]
      resources :competency_options, only: [:show, :edit, :update]
      resources :wage_steps, only: [:show, :edit, :update]
      resources :onets, only: [:index, :show]
      resources :synonyms
      resources :open_ai_prompts
      resources :word_replacements
      resources :contact_requests, only: [:index, :show]
      resources :surveys, only: [:index]
      resources :users do
        post :invite, on: :member
      end
      resources :api_keys, only: [:create, :index, :show, :destroy]
      resources :docs, only: [:index]
    end
  end

  # SEO-friendly routes for Occupation Standards
  get ":state/occupation_standards",
    to: "occupation_standards#index",
    as: :occupation_standards_by_state,
    constraints: {state: /[a-zA-Z]{2}/}

  root to: "pages#home", as: :guest_root

  resources :standards_imports, only: [:new, :create, :show]
  resources :occupation_standards, only: [:index, :show]
  resources :cookies, only: [:create]
  resources :surveys, only: [:create] do
    collection do
      post :dismiss
    end
  end
  resources :occupations, only: [:index], defaults: {format: :json}
  resources :industries, only: [:index]
  resources :states, only: [:index]
  get "home", as: :home_page, to: "pages#home"
  get "about", as: :about_page, to: "pages#about"
  get "definitions", as: :definitions_page, to: "pages#definitions"
  get "terms", as: :terms_page, to: "pages#terms"
  get "contact", as: :contact_page, to: "contact_requests#new"
  get "fact_sheets", as: :fact_sheets_page, to: "pages#fact_sheets"
  resources :contact_requests, only: [:create]

  namespace :api do
    namespace :v1 do
      jsonapi_resources :occupations
      jsonapi_resources :standards
    end
  end
end
