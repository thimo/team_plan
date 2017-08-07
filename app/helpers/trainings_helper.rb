module TrainingsHelper
  def starts_ends(training)
    "#{I18n.l(training.started_at.to_time, format: :short)} - #{I18n.l(training.ended_at.to_time, format: :short)}"
  end

  def training_title(training)
    "#{I18n.t training.class.name.downcase} - #{I18n.l training.started_at.to_date, format: :weekday} #{I18n.l training.started_at.to_date, format: :short} #{I18n.l training.started_at.to_time, format: :short}" 
  end
end
