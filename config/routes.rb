Rails.application.routes.draw do
  root to: "seasons#show"
  devise_for :users

  resources :seasons, shallow: true do
    resources :age_group_bulk_updates, only: [:new, :create]
    resources :age_groups, shallow: true do
      resources :team_bulk_updates, only: [:new, :create]
      resources :member_allocations, only: [:index, :create, :update, :destroy]
      resources :teams, except: [:index], shallow: true do
        resources :comments, only: [:new, :create, :edit, :update, :destroy]
        resources :team_member_bulk_updates, only: [:new, :create]
      end
    end
  end

  resources :team_members, only: [:show, :create, :update, :destroy], shallow: true do
    resources :comments, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :members, only: [] do
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
