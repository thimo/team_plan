class Admin::Knvb::MatchesController < Admin::BaseController
  def index
    @not_played_matches = policy_scope(Match).own.not_played.asc.in_period(0.days.ago.beginning_of_day, 1.week.from_now.end_of_day).group_by{ |match| match.wedstrijddatum.to_date }
    @played_matches = policy_scope(Match).own.played.desc.in_period(1.week.ago.end_of_day, 0.days.from_now.end_of_day).group_by{ |match| match.wedstrijddatum.to_date }
  end
end
