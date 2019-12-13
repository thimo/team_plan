# frozen_string_literal: true

module PnotifyHelper
  def pnotify_type(message_type)
    case message_type
    when "success", "notice"
      "success"
    when "alert", "warning"
      "notice"
    when "danger", "error"
      "error"
    else
      "info"
    end
  end

  def pnotify_duration(message_type)
    case message_type
    when "success", "notice"
      4000
    when "alert", "warning"
      8000
    when "danger", "error"
      8000
    else
      4000
    end
  end
end
