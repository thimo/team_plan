# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout "error"

  def file_not_found
    authorize :error
  end

  def unprocessable
    authorize :error
  end

  def internal_server_error
    authorize :error
  end
end
