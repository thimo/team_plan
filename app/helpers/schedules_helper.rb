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
end
