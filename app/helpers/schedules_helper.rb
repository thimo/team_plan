module SchedulesHelper
  include ActionView::Helpers::TagHelper

  def schedule_title(object, no_html: false)
    case [object.class]
    when [ClubDataMatch]
      "#{object.thuisteam} - #{object.uitteam}".html_safe
    when [Match]
      teams = ["#{Setting['club.name_short']} #{object.team.name}", object.opponent]
      if object.location_opponent?
        teams.reverse * ' - '
      else
        teams * ' - '
      end
    when [Training]
      "#{I18n.t object.model_name.singular}"
    end
  end

  def is_thuisteam? object
    object.is_a?(ClubDataMatch) && object&.teams&.map{ |team| team.club_data_team.teamcode }.include?(object.thuisteamid)
  end

  def is_uitteam? object
    object.is_a?(ClubDataMatch) && object&.teams&.map{ |team| team.club_data_team.teamcode }.include?(object.uitteamid)
  end

end
