require 'googleauth'
require 'google/apis/calendar_v3'

class GoogleCalendar

  def initialize
    authorize
  end

  def service
    @service
  end
  
  def events(reload=false)
    @events = nil if reload
    @events ||= service.list_events(calendar_id, max_results: 2500).items

    puts "~~~~"*2
    puts service.list_events(calendar_id, max_results: 2500).items
    puts "~~~~"*2

 #    response = service.list_events(calendar_id,
 #                               max_results:   10,
 #                               single_events: true,
 #                               order_by:      "startTime",
 #                               time_min:      DateTime.now.rfc3339)
	# puts "Upcoming events:"
	# puts "No upcoming events found" if response.items.empty?

	@events.each do |event|
	  start = event.start.date || event.start.date_time
	  puts "- #{event.summary} (#{start})"
	end
  end

  def create_event
  	event = Google::Apis::CalendarV3::Event.new(
	  summary: 'Google I/O 2015',
	  location: '800 Howard St., San Francisco, CA 94103',
	  description: 'A chance to hear more about Google\'s developer products.',
	  start: Google::Apis::CalendarV3::EventDateTime.new(
	    date_time: '2021-05-28T09:00:00-07:00',
	    time_zone: 'America/Los_Angeles'
	  ),
	  end: Google::Apis::CalendarV3::EventDateTime.new(
	    date_time: '2021-05-28T17:00:00-07:00',
	    time_zone: 'America/Los_Angeles'
	  ),
	  recurrence: [
	    'RRULE:FREQ=DAILY;COUNT=2'
	  ],
	  # attendees: [
	  #   Google::Apis::CalendarV3::EventAttendee.new(
	  #     email: 'emailany@gmail.com'
	  #   ),
	  #   Google::Apis::CalendarV3::EventAttendee.new(
	  #     email: 'emailako2.0@gmail.com'
	  #   )
	  # ],
	  reminders: Google::Apis::CalendarV3::Event::Reminders.new(
	    use_default: false,
	    overrides: [
	      Google::Apis::CalendarV3::EventReminder.new(
	        reminder_method: 'email',
	        minutes: 24 * 60
	      ),
	      Google::Apis::CalendarV3::EventReminder.new(
	        reminder_method: 'popup',
	        minutes: 10
	      )
	    ]
	  )
	)
	result = service.insert_event(calendar_id, event)
	puts "Event created: #{result.html_link}"
  end

private

  def calendar_id
    @calendar_id ||= "my_calendar_id_in_parameters"
  end

  def authorize
    calendar = Google::Apis::CalendarV3::CalendarService.new
    calendar.client_options.application_name = 'Project name' # This is optional
    calendar.client_options.application_version = '0.0.0.1' # This is optional

    ENV['GOOGLE_APPLICATION_CREDENTIALS'] = "./credential_file_05566b376ab4.json"
    scopes = [Google::Apis::CalendarV3::AUTH_CALENDAR]
    calendar.authorization = Google::Auth.get_application_default(scopes)

    @service = calendar
  end

end

cal = GoogleCalendar.new
puts "~~~~~~~~~~~~LIST EVENT"
cal.events
puts "~~~~~~~~~~~~CREATE EVENT"
cal.create_event
puts "~~~~~~~~~~~~"
