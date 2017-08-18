class Admin::ClubData::RankingsImportController < ApplicationController
  def new
    authorize ClubDataCompetition

    # TODO Move to create with POST action
    # Import URL
    ClubDataCompetition.active.each do |competition|
      json = JSON.load(open("#{Setting['clubdata.urls.poulestand']}&poulecode=#{competition.poulecode}&client_id=#{Setting['clubdata.client_id']}"))
      if json.present?
        competition.ranking = json
        competition.save
      end
    end

    redirect_to admin_club_data_competitions_path
  end

  def create
  end
end
