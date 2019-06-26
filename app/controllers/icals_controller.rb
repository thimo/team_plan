# frozen_string_literal: true

class IcalsController < ApplicationController
  require "icalendar/tzinfo"

  def show
    skip_authorization

    team = Team.active.find_by(uuid: params[:id])
    return render plain: "" if team.nil?

    user = User.find_by(uuid: params[:check])
    return render plain: "" if user.nil?

    schedules = team.matches.niet_afgelast.in_period(1.month.ago, 3.months.from_now) \
                  + team.trainings.in_period(1.month.ago, 3.months.from_now)

    respond_to do |format|
      format.html
      # format.ics { render text: Ical.new(@myevents).to_ical }
      format.ics do
        cal = Icalendar::Calendar.new
        tzid = "Europe/Amsterdam"
        tz = TZInfo::Timezone.get(tzid)

        cal.append_custom_property("X-WR-CALNAME", "#{Tenant.setting('club.name_short')} #{team.name}")
        schedules.each do |schedule|
          timezone = tz.ical_timezone(schedule.started_at)
          cal.add_timezone timezone

          event = Icalendar::Event.new
          event.dtstart = schedule.started_at
          event.dtend = schedule.ended_at
          event.summary = schedule.title
          event.description = schedule.description
          event.location = schedule.location
          cal.add_event(event)
        end
        cal.publish
        render plain: cal.to_ical
      end
    end
  end
end
