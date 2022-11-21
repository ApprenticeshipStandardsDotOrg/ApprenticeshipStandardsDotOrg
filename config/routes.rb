Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions"
  }

  root to: "standards_imports#new"
  resources :standards_imports, only: [:new, :create, :show]
  resources :file_imports, only: [:index]
end
