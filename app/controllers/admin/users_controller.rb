class Admin::UsersController < AdminController
  before_action :create_user, only: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :breadcumbs

  def index
    @users = policy_scope(User).all
  end

  def new; end

  def create
    generated_password = Devise.friendly_token.first(8)
    @user.password = generated_password
    if @user.save
      redirect_to admin_users_path, notice: 'Gebruiker is toegevoegd.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes(user_params)
      redirect_to admin_users_path, notice: 'Gebruiker is aangepast.'
    else
      render 'edit'
    end
  end

  private

  def create_user
    @user = if action_name == 'new'
              User.new
            else
              User.new(user_params)
            end
    authorize @user
  end

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end

  def user_params
    params.require(:user).permit(:first_name, :middle_name, :last_name, :email)
  end

  def breadcumbs
    add_breadcrumb 'Gebruikers', admin_users_path
    unless @user.nil?
      if @user.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb @user.name, [:edit, :admin, @user]
      end
    end
  end
end
