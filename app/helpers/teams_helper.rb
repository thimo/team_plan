module TeamsHelper
  def team_presence_graphs
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
end
