module TrainingsHelper
  def starts_ends(training)
    "#{I18n.l(training.started_at, format: :time_short)} - #{I18n.l(training.ended_at, format: :time_short)}"
  end

  def training_title(training)
    "#{I18n.t training.model_name.singular} - #{I18n.l training.started_at, format: :weekday} #{I18n.l training.started_at, format: :date_time_short}"
  end
end
