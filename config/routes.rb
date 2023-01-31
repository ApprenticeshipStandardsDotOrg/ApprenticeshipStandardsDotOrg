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
        root to: "file_imports#index"
        mount Sidekiq::Web => "/sidekiq", :as => :sidekiq
      end
    end

    resources :file_imports, only: [:index, :edit, :update]
    resources :data_imports
    resources :occupation_standards, only: [:index, :show]
  end

  root to: "standards_imports#new", as: :guest_root

  resources :standards_imports, only: [:new, :create, :show]

  namespace :api do
    namespace :v1 do
      jsonapi_resources :occupations
    end
  end
end
