module Admin
  class UsersController < Admin::BaseController
    before_action :create_resource, only: [:new, :create]
    before_action :set_resource, only: [:show, :edit, :update, :resend_password, :destroy, :impersonate]
    before_action :add_breadcrumbs

    def index
      @users = policy_scope(User).member.asc.filter_results(params.slice(:query)).includes(:members)
      @users = params[:inactive] ? @users.archived : @users.active
      @users = @users.page(params[:page]).per(50)
      authorize @users
    end

    def show
    end

    def new
      prefill_from_member
    end

    def create
      generated_password = @user.set_new_password
      @user.skip_confirmation!
      if @user.save
        @user.send_new_account(generated_password)
        flash_message(:success, "Gebruiker is toegevoegd.")
        if params[:member].present?
          redirect_to policy_scope(Member).find(params[:member])
        else
          redirect_to admin_users_path
        end
      else
        render :new
      end
    end

    def edit
    end

    def update
      @user.skip_reconfirmation!
      if @user.update(permitted_attributes(@user))
        redirect_to admin_users_path, notice: "Gebruiker is aangepast."
      else
        render "edit"
      end
    end

    def resend_password
      generated_password = @user.set_new_password
      if @user.save
        @user.send_password_reset(generated_password)
        redirect_to admin_users_path, notice: "Er is een nieuw wachtwoord aan de gebruiker verstuurd."
      else
        flash.now[:alert] = "Er kon geen nieuw wachtwoord worden verstuurd."
        render "edit"
      end
    end

    def destroy
      @user.to_archive
      redirect_to admin_users_path, notice: "Gebruiker is verwijderd."
    end

    def impersonate
      impersonate_user(@user)
      redirect_to root_path
    end

    private

    def create_resource
      @user = if action_name == "new"
        User.new
      else
        User.new(permitted_attributes(User.new))
      end
      authorize @user
    end

    def set_resource
      @user = User.find(params[:id])
      authorize @user
    end

    def add_breadcrumbs
      add_breadcrumb "Gebruikers", admin_users_path
      return if @user.nil?

      if @user.new_record?
        add_breadcrumb "Nieuw"
      else
        add_breadcrumb @user.email, [:edit, :admin, @user]
      end
    end

    def prefill_from_member
      return if params[:member].blank?

      member = policy_scope(Member).find(params[:member])
      @user.prefill(member)
    end
  end
end
