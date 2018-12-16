# frozen_string_literal: true

class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :create_login, :resend_password]
  before_action :add_breadcrumbs

  def show
    @team_members = policy_scope(@member.team_members).recent_first.includes_parents
    @todos = policy_scope(@member.todos).unfinished.asc
    @injuries = policy_scope(@member.injuries).desc.page(params[:injury_page]).per(3)
    @player_evaluations = policy_scope(@member.player_evaluations).finished_desc if policy(@member).show_evaluations?
  end

  def edit; end

  def create_login
    @user = User.find_or_create_by(email: @member.email)
    @user.prefill(@member)
    @user.status = :active
    generated_password = @user.set_new_password
    @user.skip_confirmation!

    if @user.save
      @user.send_new_account(generated_password)
      flash_message(:success, "Login is aangemaakt en verstuurd naar #{@user.email}.")
    else
      flash_message(:alert, "Login kon niet worden aangemaakt")
    end
    redirect_to @member
  end

  def resend_password
    generated_password = @member.user.set_new_password
    if @member.user.save
      @member.user.send_password_reset(generated_password)
      flash_message(:success, "Er is een nieuw wachtwoord aan #{@member.user.email} verstuurd.")
    else
      flash_message(:alert, "Er kon geen nieuw wachtwoord worden verstuurd.")
    end
    redirect_to @member
  end

  private

    def set_member
      @member = Member.find(params[:id])
      authorize @member
    end

    def add_breadcrumbs
      if @member
        team = @member.active_team # default
        team = @member.active_team_member.team if @member.active_team_member.present?

        if team.present?
          add_breadcrumb team.age_group.season.name, team.age_group.season
          add_breadcrumb team.age_group.name, team.age_group
          add_breadcrumb team.name_with_club, team
        end

        add_breadcrumb @member.name, @member
      else
        add_breadcrumb "Leden"
      end
    end
end
