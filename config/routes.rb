Rails.application.routes.draw do
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

  root to: "standards_imports#new"
  resources :standards_imports, only: [:new, :create, :show]
  resources :file_imports, only: [:index]
end
