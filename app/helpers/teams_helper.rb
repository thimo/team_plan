# frozen_string_literal: true

module TeamsHelper
  def team_presence_graphs
    # FIXME: convert to helper/model
    return unless policy(@team).show_presence_chart?

    @training_presences_data = {
      labels: [],
      datasets: [
        {
          label: "Op tijd aanwezig",
          stack: "Training",
          backgroundColor: "rgba(70, 195, 95, .7)",
          borderColor: "rgba(70, 195, 95, 1)",
          data: []
        },
        {
          label: "Iets te laat",
          stack: "Training",
          backgroundColor: "rgba(255, 218, 78, .7)",
          borderColor: "rgba(255, 218, 78, 1)",
          data: []
        },
        {
          label: "Veel te laat",
          stack: "Training",
          backgroundColor: "rgba(242, 152, 36, .7)",
          borderColor: "rgba(242, 152, 36, 1)",
          data: []
        },
        {
          label: "Niet afgemeld",
          stack: "Training",
          backgroundColor: "rgba(250, 66, 74, .7)",
          borderColor: "rgba(250, 66, 74, 1)",
          data: []
        }
      ]
    }

    ids = @team.trainings.active.in_past.pluck(:id)
    @team.team_members.active_or_archived.player.asc.each do |team_member|
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
          label: "Op tijd aanwezig",
          stack: "Wedstrijd",
          backgroundColor: "rgba(70, 195, 95, .7)",
          borderColor: "rgba(70, 195, 95, 1)",
          data: []
        },
        {
          label: "Iets te laat",
          stack: "Wedstrijd",
          backgroundColor: "rgba(255, 218, 78, .7)",
          borderColor: "rgba(255, 218, 78, 1)",
          data: []
        },
        {
          label: "Veel te laat",
          stack: "Wedstrijd",
          backgroundColor: "rgba(242, 152, 36, .7)",
          borderColor: "rgba(242, 152, 36, 1)",
          data: []
        },
        {
          label: "Niet afgemeld",
          stack: "Wedstrijd",
          backgroundColor: "rgba(250, 66, 74, .7)",
          borderColor: "rgba(250, 66, 74, 1)",
          data: []
        }
      ]
    }

    ids = @team.matches.active.in_past.pluck(:id)
    @team.team_members.active_or_archived.player.asc.each do |team_member|
      @match_presences_data[:labels] << team_member.name

      presences = team_member.member.presences.for_match(ids)
      @match_presences_data[:datasets][0][:data] << presences.present.on_time.size
      @match_presences_data[:datasets][1][:data] << presences.present.a_bit_too_late.size
      @match_presences_data[:datasets][2][:data] << presences.present.much_too_late.size
      @match_presences_data[:datasets][3][:data] << presences.not_present.not_signed_off.size
    end
  end

  def team_options_for_active_season(include_blank: false, default: nil)
    teams = human_sort(Season.active_season_for_today.teams.active.asc, :name)
    teams_array = teams.collect { |t| [t.name_with_club, t.id] }
    teams_array.unshift(["", ""]) if include_blank
    options_for_select(teams_array, default)
  end
end
