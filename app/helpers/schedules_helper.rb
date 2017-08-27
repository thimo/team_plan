module SchedulesHelper
  def schedule_title(object)
    case [object.class]
    when [ClubDataMatch]
      object.wedstrijd
    when [Match]
      teams = ["#{Setting['club.name_short']} #{object.team.name}", object.opponent]
      if object.location_opponent?
        teams.reverse * ' - '
      else
        teams * ' - '
      end
    when [Training]
      "#{I18n.t object.model_name.singular} - #{I18n.l object.started_at, format: :weekday} #{I18n.l object.started_at, format: :date_time_short}"
    end
  end

  def schedule_match_thuis(object)
    tag.span(object.thuisteam, class: "#{'strong' if object.thuisteamid == object&.team&.club_data_team.teamcode}")
  end

  def schedule_match_uit(object)
    tag.span(object.uitteam, class: "#{'strong' if object.uitteamid == object&.team&.club_data_team.teamcode}")
  end
end
