# frozen_string_literal: true

class ClubDataTeamCompetition < ApplicationRecord
  belongs_to :club_data_team
  belongs_to :competition
end
