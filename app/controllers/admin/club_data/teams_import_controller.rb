class Admin::ClubData::TeamsImportController < ApplicationController
  def new
    authorize ClubDataTeam
    
    # TODO Move to create with POST action
    # Import URL
    json = JSON.load(open("#{Setting['clubdata.urls.competities']}&client_id=#{Setting['clubdata.client_id']}"))
    json.each do |data|
      team = ClubDataTeam.find_or_initialize_by(teamcode: data['teamcode'])
      %w[teamnaam spelsoort geslacht teamsoort leeftijdscategorie kalespelsoort speeldag speeldagteam].each do |field|
        team.write_attribute(field, data[field])
      end
      team.save
    end

    redirect_to admin_club_data_teams_path
  end

  def create
  end
end
