module MatchesHelper
  def match_title(match)
    teams = ["#{Setting['club.name_short']} #{match.team.name}", match.opponent]
    if match.home_match?
      teams * ' - '
    else
      teams.reverse * ' - '
    end
  end
end
