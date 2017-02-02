Rails.application.routes.draw do
  root to: "seasons#show"
  devise_for :users

  resources :seasons, shallow: true do
    resources :year_groups, shallow: true do
      resources :teams, except: [:index], shallow: true do
        resources :team_members, except: [:index] do
          resources :comments, only: [:new, :create, :edit, :update, :destroy]
        end
        resources :comments, only: [:new, :create, :edit, :update, :destroy]
      end
      resources :team_bulk_updates, only: [:new, :create]
    end
    resources :year_group_bulk_updates, only: [:new, :create]
  end

  resources :members do
    resources :comments, only: [:new, :create, :edit, :update, :destroy]
  end

  get 'admin' => 'admin#show'
  namespace :admin do
    resources :users
    resources :members
    resources :members_import, only: [:new] do
      collection {
        post :create #, to: 'members_import#create'
      }
    end
  end

  get '/check.txt', to: proc {[200, {}, ['it_works']]}
end
