Rails.application.routes.draw do
  get "applications/index"
  get "applications/create"
  get "applications/update"
  get "notification/index"
  get "notification/mark_as_read"
  get "notification/mark_all_as_read"
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

  resources :companies, only: [ :update, :index, :show ] do
    post "create_with_recruiter", on: :collection
  end

  resources :recruiters, only: [ :create ]

  namespace :api do
    namespace :v1 do
      get "industries/show"

      resources :students, only: [ :show, :update ] do
        member do
          get :export
        end
      end

      resources :skills, only: [ :index ]

      resources :industries, only: [ :index ]

      resources :job_postings, only: [ :index, :show, :create, :update ] do
        member do
          post :toggle_active
          post :apply, to: "applications#create"
        end
      end

      resources :messages, only: [ :create ] do
        collection do
          get :conversation
          get :partners
        end
      end

      resources :notifications, only: [ :index ] do
        member do
          patch :mark_as_read
        end

        collection do
          patch :mark_all_as_read
        end
      end

      resources :applications, only: [ :index, :update ]
    end
  end
end
