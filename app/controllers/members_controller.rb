class MembersController < ApplicationController
  before_action :add_breadcrumbs
  before_action :set_member, only: [:show, :edit, :update]

  def show
    @team_members = policy_scope(@member.team_members).recent_first.includes_parents
  end

  def edit
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
