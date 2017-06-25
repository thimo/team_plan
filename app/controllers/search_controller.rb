class SearchController < ApplicationController
  def show
    @query = params[:query]
    @members = Member.active.asc.search_by_name(@query)
    authorize Member
  end
end
