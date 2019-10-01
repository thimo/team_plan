# frozen_string_literal: true

module Org
  class CommentsController < Org::BaseController
    before_action :add_breadcrumbs

    def index
      @comments = policy_scope(Comment).desc.page(params[:page]).per(50)
      authorize @comments
    end

    private

      def add_breadcrumbs
        add_breadcrumb "Opmerkingen"
      end
  end
end
