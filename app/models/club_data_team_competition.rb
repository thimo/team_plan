# frozen_string_literal: true

class ClubDataTeamCompetition < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :club_data_team
  belongs_to :competition
end
