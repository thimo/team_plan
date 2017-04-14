class Admin::VersionUpdatesController < ApplicationController
  def index
    # TODO add paging
    @version_updates = policy_scope(VersionUpdate)
  end
end
