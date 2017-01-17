Rails.application.routes.draw do
  get 'members/show'

  get 'members/edit'

  devise_for :users

  shallow do
    resources :seasons do
      resources :year_groups, exept: [:index] do
        resources :teams, exept: [:index]
      end
    end
  end
  resources :members

  root to: "seasons#show"
end
