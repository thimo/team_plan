# frozen_string_literal: true

module SchedulesHelper
  include ActionView::Helpers::TagHelper

  def is_thuisteam?(object)
    object.is_a?(Match) && Team.by_teamcode(object.thuisteamid).present?
  end

  def is_uitteam?(object)
    object.is_a?(Match) && Team.by_teamcode(object.uitteamid).present?
  end
end
