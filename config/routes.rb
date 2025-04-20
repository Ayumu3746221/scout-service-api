Rails.application.routes.draw do
  get "recruiters/create"
  get "companies/create_with_cruiter"
  devise_for :users, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    registration: "signup"
  },
  controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  resources :companies, only: [] do
    post "create_with_recruiter", on: :collection
  end

  resources :recruiters, only: [ :create ]

  namespace :api do
    namespace :v1 do
      resources :students, only: [ :show, :update ]
    end
  end
end
