module PresencesHelper
  def color_for_on_time(on_time_value)
    case on_time_value.to_sym
    when :on_time, :signed_off_on_time
      "btn btn-success"
    when :a_bit_too_late, :signed_off_too_late
      "btn btn-warning"
    when :much_too_late, :not_signed_off
      "btn btn-danger"
    end
  end
end
