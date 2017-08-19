module MatchesHelper
  def match_title(match)
    case [match.class]
    when [ClubDataMatch]
      match.wedstrijd
    else
      teams = ["#{Setting['club.name_short']} #{match.team.name}", match.opponent]
      if match.location_opponent?
        teams.reverse * ' - '
      else
        teams * ' - '
      end
    end
   end

  def match_schedule_color(match)
    if match.started_at.to_date == Time.zone.today.to_date
      'table-info'
    elsif match.started_at.to_date < Time.zone.today
      'table-active'
    else
      'table-success'
    end
  end
end
