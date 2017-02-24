Rails.application.routes.draw do
  root to: "seasons#show"
  devise_for :users

  authenticate :user do
    resources :seasons, shallow: true do
      resources :age_group_bulk_updates, only: [:new, :create]
      resources :age_groups, shallow: true do
        resources :team_bulk_updates, only: [:new, :create]
        resources :member_allocations, only: [:index, :create, :update, :destroy]
        resources :favorites, only: [:create, :destroy]
        resources :teams, except: [:index], shallow: true do
          resources :comments, only: [:new, :create, :edit, :update, :destroy]
          resources :favorites, only: [:create, :destroy]
          resources :team_member_bulk_updates, only: [:new, :create]
          resources :team_evaluations, only: [:new, :create, :edit, :update, :destroy]
        end
      end
    end

    resources :team_members, only: [:show, :create, :update, :destroy], shallow: true do
      resources :comments, only: [:new, :create, :edit, :update, :destroy]
    end

    resources :members, only: [:show] do
      resources :comments, only: [:new, :create, :edit, :update, :destroy]
      resources :favorites, only: [:create, :destroy]
    end

    get 'admin' => 'admin#show'
    namespace :admin do
      resources :users, except: [:show]
      resources :members, only: [:index, :show]
      resources :members_import, only: [:new] do
        collection {
          post :create #, to: 'members_import#create'
        }
      end
    end
  end

  get '/check.txt', to: proc {[200, {}, ['it_works']]}
end
