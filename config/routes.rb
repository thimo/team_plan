Rails.application.routes.draw do
  # get 'year_groups/index'
  #
  # get 'year_groups/show'
  #
  # get 'year_groups/new'
  #
  # get 'year_groups/edit'
  #
  # get 'seasons/index'
  #
  # get 'seasons/show'
  #
  # get 'seasons/new'
  #
  # get 'seasons/edit'

  devise_for :users

  resource :seasons
  resource :year_groups

  root to: "seasons#index"
end
