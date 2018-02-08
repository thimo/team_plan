module SchedulesHelper
  include ActionView::Helpers::TagHelper

  def schedule_title(object, no_html: false)
    case [object.class]
    when [Match]
      "#{object.thuisteam} - #{object.uitteam}".html_safe
    when [Training]
      "#{I18n.t object.model_name.singular}"
    end
  end

  def is_thuisteam?(object)
    object.is_a?(Match) && Team.by_teamcode(object.thuisteamid).present?
  end

  def is_uitteam?(object)
    object.is_a?(Match) && Team.by_teamcode(object.uitteamid).present?
  end

end
