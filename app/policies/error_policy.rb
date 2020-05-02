class ErrorPolicy < Struct.new(:user, :error)
  def file_not_found?
    true
  end

  def unprocessable?
    true
  end

  def internal_server_error?
    true
  end
end
