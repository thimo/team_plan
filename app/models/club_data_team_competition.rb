# == Schema Information
#
# Table name: club_data_team_competitions
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  club_data_team_id :bigint           not null
#  competition_id    :bigint           not null
#  tenant_id         :bigint
#
# Indexes
#
#  competition_team                                (tenant_id,competition_id,club_data_team_id) UNIQUE
#  index_club_data_team_competitions_on_tenant_id  (tenant_id)
#  team_competition                                (tenant_id,club_data_team_id,competition_id) UNIQUE
#
class ClubDataTeamCompetition < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :club_data_team
  belongs_to :competition
end
