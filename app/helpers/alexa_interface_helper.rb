module AlexaInterfaceHelper

  # uses everything and returns a full response object to send to alexa
  def create_response(call_parameters)
    response_for_alexa = AlexaRubykit::Response.new
    response = call(call_parameters)
    top_ten = pick10(response)
    top_one = pick1(top_ten)
    format_speech_for_alexa(response_for_alexa, top_one)
    format_text_for_alexa(response_for_alexa, top_ten)
    response_for_alexa.build_response
  end

  # Make an api call to eventful and return an array of events (probably super huge long awful list)
  def call(call_parameters={})
    parameters_hash = { location: "San Francisco", date: "Today", sort_order: "popularity", mature: "normal" }
    client = EventfulApi::Client.new({})
    response = client.get('/events/search', parameters_hash)
    # hash > "events" > "event" > array of events
    response["events"]["event"]
  end

  # Run call, then select ten of the call items. Returns array with length 10 or less
  def pick10(call_list)
    call_list[0..9]
  end

  # Run pick ten (or run on output of pick ten, might be more DRY), picks top result. returns top result
  def pick1(ten_events)
    ten_events.first
  end

  # use the alexa gem to add speech to response for alexa. doesn't need return as it's just side effects we want
  def format_speech_for_alexa(response_for_alexa, single_event)
    event_name = single_event['title']
    venue_name = single_event['venue_name']
    start_date = single_event['start_time']
    start_time = DateTime.parse(start_date).strftime('%l:%M %p')
    response_for_alexa.add_speech("#{event_name} is happening at #{venue_name} starting at #{start_time}")
  end

  # use the alexa gem to add text cards to give to alexa's companion app. doesn't need return as it's just side effects we want
  def format_text_for_alexa(response_for_alexa, top_ten_events)

  end

  # take care of edge case where there's no description within the event hash
  def find_formatted_description(event)
    if event['description']
      format_html_text_to_string(event['description'])
    else
      'We don\'t have any details on this event'
    end
  end

  # remove br tags and &quot; formating and parse it into alexa writable strings
  def format_html_text_to_string(html_text)
    breakless_text = html_text.gsub("<br>", "\n")
    Nokogiri::HTML(breakless_text).text
  end
end
