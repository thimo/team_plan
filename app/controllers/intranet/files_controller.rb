module Intranet
  class FilesController < Intranet::BaseController
    def index
      # @files = policy_scope(IntranetFiles).arrange
      skip_policy_scope
    end
  end
end
