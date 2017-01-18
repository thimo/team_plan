Rails.application.routes.draw do
  get 'members/show'

  get 'members/edit'

  root to: "seasons#show"
  devise_for :users

  shallow do
    resources :seasons do
      resources :year_groups, except: [:index] do
        resources :teams, except: [:index] do
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
end
