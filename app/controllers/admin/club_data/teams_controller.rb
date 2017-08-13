class Admin::ClubData::TeamsController < ApplicationController
  include SortHelper

  def index
    @teams = policy_scope(ClubDataTeam).asc
  end
end
