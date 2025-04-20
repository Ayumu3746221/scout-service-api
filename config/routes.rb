Rails.application.routes.draw do
  get "skills/show"
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
      get "industries/show"
      resources :students, only: [ :show, :update ]
      resources :skills, only: [ :index ]
      resources :industries, only: [ :index ]
    end
  end
end
