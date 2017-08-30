module MatchesHelper
  def match_schedule_color(match)
    if match.started_at.to_date == Time.zone.today.to_date
      'table-info'
    # elsif match.started_at.to_date < Time.zone.today
    #   'table-active'
    else
      'table-success'
    end
  end
end
