class Org::PositionsController < ApplicationController
  def index
    @org_positions = policy_scope(OrgPosition).arrange
  end
end
