# frozen_string_literal: true

class StaticPagesController < ApplicationController
  before_action :skip_authorization

  def support
    add_breadcrumb "Support", support_path
  end

  def about
    add_breadcrumb "About", about_path
  end
end
