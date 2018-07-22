# frozen_string_literal: true

module PresencesHelper
  def color_for_on_time(on_time_value)
    case on_time_value.to_sym
    when :on_time, :signed_off_on_time
      "btn btn-outline-success"
    when :a_bit_too_late, :signed_off_too_late
      "btn btn-outline-warning"
    when :much_too_late, :not_signed_off
      "btn btn-outline-danger"
    end
  end
end
