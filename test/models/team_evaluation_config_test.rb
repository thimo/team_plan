# == Schema Information
#
# Table name: team_evaluation_configs
#
#  id         :bigint           not null, primary key
#  config     :jsonb
#  name       :string
#  status     :integer          default("draft")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :bigint
#
# Indexes
#
#  index_team_evaluation_configs_on_tenant_id  (tenant_id)
#
require 'test_helper'

class TeamEvaluationConfigTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
