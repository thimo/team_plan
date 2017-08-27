module SchedulesHelper
  include ActionView::Helpers::TagHelper

  def schedule_title(object, no_html: false)
    case [object.class]
    when [ClubDataMatch]
      "#{schedule_match_thuis(object, no_html: no_html)} - #{schedule_match_uit(object, no_html: no_html)}".html_safe

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

  def schedule_match_thuis(object, no_html: false)
    return object.thuisteam if no_html
    tag.span(object.thuisteam, class: "#{'strong' if object.thuisteamid == object&.team&.club_data_team.teamcode}")
  end

  def schedule_match_uit(object, no_html: false)
    return object.uitteam if no_html
    tag.span(object.uitteam, class: "#{'strong' if object.uitteamid == object&.team&.club_data_team.teamcode}")
  end
end
