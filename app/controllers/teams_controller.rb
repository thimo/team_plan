class TeamsController < ApplicationController
  before_action :create_team, only: [:new, :create]
  before_action :set_team, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs

  def show
    @players = TeamMember.players_by_year(policy_scope(@team.team_members).includes(:teammembers_field_positions, :field_positions).not_ended)
    @staff = TeamMember.staff_by_member(policy_scope(@team.team_members).not_ended)
    @old_members = policy_scope(@team.team_members).ended.group_by(&:member)

    @team_evaluations = policy_scope(@team.team_evaluations).desc
    @notes = Note.for_user(policy_scope(@team.notes), @team, current_user).desc
    @previous_season = @team.age_group.season.previous
    @training_schedules = policy_scope(@team.training_schedules).active.includes(:soccer_field, :team_members).asc

    todos = policy_scope(@team.todos).open.includes(:todoable)
    @todos_active = todos.active.to_a
    @todos_defered = todos.defered.to_a
    todos = policy_scope(Todo).where(todoable_type: Member.name, todoable_id: policy_scope(Member).by_team(@team).map(&:id)).open.asc
    @todos_active += todos.active
    @todos_defered += todos.defered

    @trainings = @team.trainings.in_period(0.days.ago.beginning_of_day, 2.weeks.from_now.beginning_of_day).asc
    @not_played_matches = @team.club_data_matches.not_played.in_period(0.days.ago.beginning_of_day, 3.weeks.from_now.beginning_of_day).asc
    @played_matches = @team.club_data_matches.played.in_period(3.week.ago.end_of_day, 0.days.from_now.end_of_day).desc
    @competitions = @team.club_data_competitions

    # FIXME convert to helper/model
    if policy(@team).show_presence_chart?
      @training_presences_data = {
        labels: [],
        datasets: [
          {
            label: "Training, op tijd",
            stack: "Training",
            backgroundColor: 'rgba(70, 195, 95, .7)',
            borderColor: 'rgba(70, 195, 95, 1)',
            data: [],
          },
          {
            label: "Training, iets te laat",
            stack: "Training",
            backgroundColor: 'rgba(255, 218, 78, .7)',
            borderColor: 'rgba(255, 218, 78, 1)',
            data: [],
          },
          {
            label: "Training, veel te laat",
            stack: "Training",
            backgroundColor: 'rgba(242, 152, 36, .7)',
            borderColor: 'rgba(242, 152, 36, 1)',
            data: [],
          },
          {
            label: "Training, niet afgemeld",
            stack: "Training",
            backgroundColor: 'rgba(250, 66, 74, .7)',
            borderColor: 'rgba(250, 66, 74, 1)',
            data: [],
          },
        ]
      }

      ids = @team.trainings.in_past.pluck(:id)
      @team.team_members.active.player.asc.each do |team_member|
        @training_presences_data[:labels] << team_member.name

        presences = team_member.member.presences.for_training(ids)
        @training_presences_data[:datasets][0][:data] << presences.present.on_time.size
        @training_presences_data[:datasets][1][:data] << presences.present.a_bit_too_late.size
        @training_presences_data[:datasets][2][:data] << presences.present.much_too_late.size
        @training_presences_data[:datasets][3][:data] << presences.not_present.not_signed_off.size
      end

      @match_presences_data = {
        labels: [],
        datasets: [
          {
            label: "Wedstrijd, op tijd",
            stack: "Wedstrijd",
            backgroundColor: 'rgba(70, 195, 95, .7)',
            borderColor: 'rgba(70, 195, 95, 1)',
            data: [],
          },
          {
            label: "Wedstrijd, iets te laat",
            stack: "Wedstrijd",
            backgroundColor: 'rgba(255, 218, 78, .7)',
            borderColor: 'rgba(255, 218, 78, 1)',
            data: [],
          },
          {
            label: "Wedstrijd, veel te laat",
            stack: "Wedstrijd",
            backgroundColor: 'rgba(242, 152, 36, .7)',
            borderColor: 'rgba(242, 152, 36, 1)',
            data: [],
          },
          {
            label: "Wedstrijd, niet afgemeld",
            stack: "Wedstrijd",
            backgroundColor: 'rgba(250, 66, 74, .7)',
            borderColor: 'rgba(250, 66, 74, 1)',
            data: [],
          },
        ]
      }

      ids = @team.club_data_matches.in_past.pluck(:id)
      @team.team_members.active.player.asc.each do |team_member|
        @match_presences_data[:labels] << team_member.name

        presences = team_member.member.presences.for_club_data_match(ids)
        @match_presences_data[:datasets][0][:data] << presences.present.on_time.size
        @match_presences_data[:datasets][1][:data] << presences.present.a_bit_too_late.size
        @match_presences_data[:datasets][2][:data] << presences.present.much_too_late.size
        @match_presences_data[:datasets][3][:data] << presences.not_present.not_signed_off.size
      end
    end
  end

  def new; end

  def create
    if @team.save
      redirect_to @team, notice: 'Team is toegevoegd.'
    else
      render :new
    end
  end

  def edit; end

  def update
    old_status = @team.status

    if @team.update_attributes(permitted_attributes(@team))
      @team.transmit_status(@team.status, old_status)

      redirect_to @team, notice: 'Team is aangepast.'
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to @team.age_group, notice: 'Team is verwijderd.'
    @team.destroy
  end

  private

    def create_team
      @age_group = AgeGroup.find(params[:age_group_id])

      @team = if action_name == 'new'
                @age_group.teams.new
              else
                Team.new(permitted_attributes(Team.new))
              end
      @team.age_group = @age_group

      authorize @team
    end

    def set_team
      @team = Team.find(params[:id])
      authorize @team
    end

    def add_breadcrumbs
      add_breadcrumb "#{@team.age_group.season.name}", @team.age_group.season
      add_breadcrumb @team.age_group.name, @team.age_group
      if @team.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb @team.name, @team
      end
    end
end
