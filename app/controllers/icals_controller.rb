class IcalsController < ApplicationController
  def show
    skip_authorization

    team = Team.find_by(uuid: params[:id])
    raise "Team not found" if team.nil?
    user = User.find_by(uuid: params[:check])
    raise "Check invalid" if user.nil?

    schedules = team.club_data_matches.from_now + team.trainings.in_period(0.days.ago, 2.months.from_now)

    respond_to do |format|
      format.html
      # format.ics { render text: Ical.new(@myevents).to_ical }
      format.ics do
        cal = Icalendar::Calendar.new
        cal.append_custom_property("X-WR-CALNAME","#{Setting['club.name_short']} #{team.name}")
        schedules.each do |schedule|
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

  # # app/models/ical.rb
  # class Ical < Icalendar::Calendar
  #   def initialize(events)
  #     super()
  #     events.each do |myevent|
  #       event = Icalendar::Event.new
  #       event.dtstart = myevent.event_date
  #       event.summary = myevent.name
  #       add_event(event)
  #     end
  #     publish
  #   end
  # end
end
