# frozen_string_literal: true

Rails.application.routes.draw do
  get "support", to: "static_pages#support"
  get "about", to: "static_pages#about"

  # Devise setup, with limit on creating new accounts
  devise_for :users

  authenticate :user do
    root to: "dashboards#show"

    get "dashboard" => "dashboards#show"
    resource :dashboards do
      collection do
        get :program
        get :results
        get :cancellations
      end
    end
    resources :matches
    resources :seasons, shallow: true do
      member do
        post :inherit_age_groups
      end
      resources :age_group_bulk_updates, only: [:new, :create]
      resources :download_team_members, only: [:index]
      resources :publish_team_members, only: [:index]
      resources :team_actions, only: [:new, :create]
      resources :age_groups, shallow: true do
        resources :team_bulk_updates, only: [:new, :create]
        resources :team_evaluation_bulk_updates, only: [:new, :create]
        resources :member_allocations, only: [:index, :create, :update, :destroy]
        resources :favorites, only: [:create, :destroy]
        resources :download_team_members, only: [:index]
        resources :team_actions, only: [:new, :create]
        resources :select_teams
        resources :todos, only: [:new, :create]
        resources :teams, except: [:index], shallow: true do
          resources :team_members, only: [:new, :create]
          resources :comments, only: [:index, :new, :create, :edit, :update, :destroy] do
            collection do
              post :toggle_include_member
            end
          end
          resources :notes, only: [:show, :new, :create, :edit, :update, :destroy]
          resources :favorites, only: [:create, :destroy]
          resources :team_member_bulk_updates, only: [:new, :create]
          resources :team_evaluations, only: [:new, :create, :edit, :update, :destroy]
          resources :download_team_members, only: [:index]
          resources :todos, only: [:new, :create]
          resources :training_schedules do
            resources :presences
            member do
              post :activate
            end
          end
          resources :trainings, shallow: true do
            resources :presences
          end
          resources :matches do
            resources :presences
          end
          resources :schedules
        end
        resources :group_members, only: [:new, :create]
      end
    end

    resources :team_evaluations, only: [:show, :edit, :update] do
      member do
        post :re_open
      end
    end
    resources :team_members, only: [:show, :create, :edit, :update, :destroy] do
      member do
        post :activate
      end
    end
    resources :member_allocation_filters, only: [:create, :destroy]
    resources :members, only: [:show], shallow: true do
      member do
        post :create_login
        post :resend_password
      end
      resources :comments, only: [:new, :create, :edit, :update, :destroy]
      resources :favorites, only: [:create, :destroy]
      resources :todos, only: [:new, :create]
      resources :injuries, only: [:show, :new, :create, :edit, :update, :destroy] do
        resources :comments, only: [:new, :create, :edit, :update, :destroy]
      end
    end
    resources :users, only: [] do
      post :stop_impersonating, on: :collection
    end
    resources :search
    resources :todos do
      member do
        post :toggle
      end
    end
    resources :competitions, only: [:show]
    resources :comments, only: [] do
      collection do
        post :set_active_tab
      end
    end
    resources :group_members, only: [:new, :create, :destroy]

    get "org" => "org/base#show"
    namespace :org do
      resources :members, only: [:index]
      resources :seasons, only: [:show]
    end

    get "intranet" => "intranet/base#show"
    namespace :intranet do
      resources :files
    end

    get "admin" => "admin/base#show"
    namespace :admin do
      resources :users, except: [:show], shallow: true do
        resources :email_logs, only: [:index, :show]
        member do
          get :resend_password
          post :impersonate
        end
      end
      resources :members, only: [:index]
      resources :members_import, only: [:new, :create]
      resources :email_logs, only: [:index, :show]
      resources :version_updates
      namespace :knvb do
        resources :dashboards
        resources :club_data_teams
        resources :club_data_teams_import, only: [:new]
        resources :club_data_team_photos_import, only: [:new]
        resources :competitions
        resources :competitions_import, only: [:new]
        resources :matches
        resources :club_data_results_import, only: [:new]
        resources :logs
      end
      resources :soccer_fields
      resources :competitions
      resources :groups, shallow: true do
        resources :group_members
      end
      resources :roles
      resources :groups_roles do
        collection do
          delete :destroy
        end
      end
      resources :matches
      resources :play_bans
      resources :play_bans_import, only: [:new, :create]
      resources :tenant_settings, only: [:edit, :update]
    end
  end

  resources :icals, only: [:show]

  get "/check.txt", to: proc { [200, {}, ["it_works"]] }
  match "/404", to: "errors#file_not_found", via: :all
  match "/422", to: "errors#unprocessable", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
end
