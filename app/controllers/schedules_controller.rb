class SchedulesController < ApplicationController
  before_action :set_team, only: [:index]
  before_action :add_breadcrumbs

  def index
    date = params[:start_date].present? ? Time.zone.parse(params[:start_date]) : Time.zone.now

    @schedules = @team.schedules(from: date - 1.month, up_to: date + 1.month)
    skip_policy_scope
  end

  private

    def set_team
      @team = Team.find(params[:team_id])
      authorize @team, :show_schedules?
    end

    def add_breadcrumbs
      # add_breadcrumb "#{@team.age_group.season.name}", @team.age_group.season
      add_breadcrumb @team.age_group.name, @team.age_group
      add_breadcrumb @team.name_with_club, @team
      add_breadcrumb "Kalender"
    end
end
