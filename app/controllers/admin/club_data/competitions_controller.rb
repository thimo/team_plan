class Admin::ClubData::CompetitionsController < ApplicationController
  def index
    @competitions = policy_scope(ClubDataCompetition).active.asc
  end
end
