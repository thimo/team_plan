class MembersController < ApplicationController
  before_action :add_breadcrumbs
  before_action :set_member, only: [:show, :edit, :update, :create_login, :resend_password]

  def show
    @team_members = policy_scope(@member.team_members).recent_first.includes_parents
    @todos = policy_scope(@member.todos).open
    @injuries = policy_scope(@member.injuries).page(params[:injury_page]).per(3)
  end

  def edit
  end

  def create_login
    @user = User.new
    @user.prefill(@member)
    generated_password = @user.set_new_password
    @user.skip_confirmation!

    if @user.save
      @user.send_new_account(generated_password)
      flash[:success] = "Login is aangemaakt en verstuurd naar #{@user.email}."
    else
      flash[:alert] = "Login kon niet worden aangemaakt"
    end
    redirect_to @member
  end

  def resend_password
    generated_password = @member.user.set_new_password
    if @member.user.save
      @member.user.send_password_reset(generated_password)
      flash[:success] = "Er is een nieuw wachtwoord aan #{@member.user.email} verstuurd."
    else
      flash[:alert] = 'Er kon geen nieuw wachtwoord worden verstuurd.'
    end
    redirect_to @member
  end

  private

    def set_member
      @member = Member.find(params[:id])
      authorize @member

      team = @member.active_team # default
      team = @member.active_team_member.team if @member.active_team_member.present?

      if team.present?
        add_breadcrumb "#{team.age_group.season.name}", team.age_group.season
        add_breadcrumb "#{team.age_group.name}", team.age_group
        add_breadcrumb "#{team.name}", team
      end
      add_breadcrumb "#{@member.name}", @member
    end

    def add_breadcrumbs
      add_breadcrumb "Leden"
    end

end
