# frozen_string_literal: true

module TrainingsHelper
  def starts_ends(training)
    "#{I18n.l(training.started_at, format: :time_short)} - #{I18n.l(training.ended_at, format: :time_short)}"
  end
end
