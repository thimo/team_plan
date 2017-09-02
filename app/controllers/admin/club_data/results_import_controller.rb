class Admin::ClubData::ResultsImportController < AdminController
  def new
    authorize ClubDataMatch

    # Import URL
    json = JSON.load(open("#{Setting['clubdata.urls.uitslagen']}&client_id=#{Setting['clubdata.client_id']}"))
    json.each do |data|
      club_data_match = ClubDataMatch.find_by(wedstrijdcode: data['wedstrijdcode'])

      if club_data_match.present?
        club_data_match.update(uitslag: data["uitslag"])
      end
    end

    redirect_to admin_club_data_matches_path
  end
end
