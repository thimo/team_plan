# frozen_string_literal: true

module Admin::Knvb::LogsHelper
  def log_row_icon(log)
    case log.level
    when "error"
      tag.i(class: [fa_class, "fa-ban", "color-red"])
    when "warning"
      tag.i(class: [fa_class, "fa-exclamation-triangle", "color-orange"])
    when "debug"
      tag.i(class: [fa_class, "fa-bug", "color-yellow"])
    when "info"
      tag.i(class: [fa_class, "fa-info-circle", "color-green"])
    end
  end
end
