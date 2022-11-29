Rails.application.routes.draw do
  constraints(Subdomain) do
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
      end
    end
  end

  root to: "standards_imports#new", as: :guest_root

  resources :standards_imports, only: [:new, :create, :show]
  resources :file_imports, only: [:index]
end
