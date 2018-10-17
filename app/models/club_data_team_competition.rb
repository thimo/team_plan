# frozen_string_literal: true

class ClubDataTeamCompetition < ApplicationRecord
  multi_tenant :tenant
  belongs_to :club_data_team
  belongs_to :competition
end
