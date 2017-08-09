module MatchesHelper
  def match_title(match)
    teams = [match.team.name, match.opponent]
    if match.home_match?
      teams * ' - '
    else
      teams.reverse * ' - '
    end
  end
end
