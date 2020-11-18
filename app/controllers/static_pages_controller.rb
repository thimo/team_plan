class StaticPagesController < ApplicationController
  before_action :skip_authorization

  def about
    add_breadcrumb "About", about_path
  end
end
