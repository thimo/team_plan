module TrainingsHelper
  def starts_ends(training)
    "#{I18n.l(training.started_at.to_time, format: :short)} - #{I18n.l(training.ended_at.to_time, format: :short)}"
  end
end
