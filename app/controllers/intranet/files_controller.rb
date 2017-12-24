class Intranet::FilesController < ApplicationController
  def index
    # @files = policy_scope(IntranetFiles).arrange
    skip_policy_scope
  end
end
