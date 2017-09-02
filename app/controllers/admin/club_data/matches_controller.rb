class Admin::ClubData::MatchesController < ApplicationController
  def index
    @not_played_matches = policy_scope(ClubDataMatch).own.not_played.asc.limit(100).group_by{ |match| match.wedstrijddatum.to_date }
    @played_matches = policy_scope(ClubDataMatch).own.played.desc.limit(100).group_by{ |match| match.wedstrijddatum.to_date }
  end
end
