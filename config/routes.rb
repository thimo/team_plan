Rails.application.routes.draw do
  get 'support', to: 'static_pages#support'
  get 'about', to: 'static_pages#about'

  root to: "dashboards#index"

  # Devise setup, with limit on creating new accounts
  devise_for :users, :skip => [:registrations]
  as :user do
    get 'users/new' => 'devise/registrations#new', :as => 'new_user_registration'
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  authenticate :user do
    resources :dashboard, only: [:index], controller: :dashboards
    resources :seasons, shallow: true do
      resources :age_group_bulk_updates, only: [:new, :create]
      resources :download_team_members, only: [:index]
      resources :age_groups, shallow: true do
        resources :team_bulk_updates, only: [:new, :create]
        resources :member_allocations, only: [:index, :create, :update, :destroy]
        resources :favorites, only: [:create, :destroy]
        resources :download_team_members, only: [:index]
        resources :team_actions, only: [:new, :create]
        resources :select_teams
        resources :teams, except: [:index], shallow: true do
          resources :team_members, only: [:new, :create]
          resources :comments, only: [:new, :create, :edit, :update, :destroy]
          resources :notes, only: [:show, :new, :create, :edit, :update, :destroy]
          resources :favorites, only: [:create, :destroy]
          resources :team_member_bulk_updates, only: [:new, :create]
          resources :team_evaluations, only: [:new, :create, :edit, :update, :destroy]
          resources :download_team_members, only: [:index]
        end
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

    resources :members, only: [:show] do
      resources :comments, only: [:new, :create, :edit, :update, :destroy]
      resources :favorites, only: [:create, :destroy]
    end
    resources :users, only: [] do
      post :stop_impersonating, on: :collection
    end
    resources :search

    get 'admin' => 'admin#show'
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
      resources :settings,
        :constraints => { :id => /[^\/]+(?=\.html\z|\.json\z)|[^\/]+/ }
    end
  end

  get '/check.txt', to: proc {[200, {}, ['it_works']]}
  match '/404', to: 'errors#file_not_found', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
