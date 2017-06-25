class SearchController < ApplicationController
  before_action :add_breadcrumbs

  def show
    @query = params[:query]
    @members = Member.active.asc.search_by_name(@query)
    authorize Member
  end

  private

    def add_breadcrumbs
      add_breadcrumb 'Zoekresultaten'
    end
end
