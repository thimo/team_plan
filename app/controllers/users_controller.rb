class UsersController < ApplicationController
  def stop_impersonating
    stop_impersonating_user
    authorize current_user
    redirect_to root_path
  end
end
