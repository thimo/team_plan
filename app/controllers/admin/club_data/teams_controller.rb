class Admin::ClubData::TeamsController < ApplicationController
  def index
    @teams = policy_scope(ClubDataTeam)
  end
end
