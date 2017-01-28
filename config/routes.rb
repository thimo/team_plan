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
    end
  end

  resources :members do
    resources :comments, only: [:new, :create, :edit, :update, :destroy]
  end
end
