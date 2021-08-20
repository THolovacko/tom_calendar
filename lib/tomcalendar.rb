require 'aws-sdk-dynamodb'
require 'googleauth/client_id'
require 'googleauth/web_user_authorizer'
require 'googleauth/token_store'
require "google/apis/calendar_v3"
require 'json'
require 'digest'
require 'jwt'
require 'aws-sdk-s3'
require 'time'
require 'tzinfo'
require 'uri'
require 'cgi'

def exponential_backoff(&block)
  retries = 0
  begin
    block.call
  rescue StandardError => e
    if retries <= 5
      sleep( (2 ** retries) * 0.1 )
      retries = retries + 1
      retry
    end
    raise
  end
end

module StatusCodeStr
  OK           = "Content-type: text/plain\nStatus: 200 OK\n\n".freeze
  BAD_REQUEST  = "Content-type: text/plain\nStatus: 400 Bad Request\n\n".freeze
  UNAUTHORIZED = "Content-type: text/plain\nStatus: 401 Unauthorized\n\n".freeze
  INTERNAL_SERVER_ERROR = "Content-type: text/plain\nStatus: 500 Internal Server Error\n\n".freeze

  def self.bad_request_error_message(message)
    "Content-type: text/plain\nStatus: 400 #{message}\n\n".freeze
  end

  def self.error_message(message)
    "Content-type: text/plain\nStatus: 500 #{message}\n\n".freeze
  end

  def self.plain_text(message)
    "Content-type: text/plain\n\n#{message}".freeze
  end

  def self.json(message)
    "Content-type: application/json\n\n#{message.is_a?(String) ? message : message.to_json}".freeze
  end
end

GOOGLE_PERMISSION_SCOPES = ['profile', 'email', 'https://www.googleapis.com/auth/calendar'].freeze
APPLICATION_NAME = 'TomCalendar'.freeze

class DynamoDBTokenStore < Google::Auth::TokenStore
  def initialize(dynamodb_connection)
    @dynamodb = dynamodb_connection
  end

  def store(id, token)
    item = JSON.parse(token)
    item[:id] = id
    
    params = {
      table_name: 'GoogleTokens',
      item: item
    }

    begin
      @dynamodb.put_item(params)
    rescue Aws::DynamoDB::Errors::ServiceError => error
      raise "Unable to add token: #{item.to_s}"
    end
  end

  def load(id)
    params = {
      table_name: 'GoogleTokens',
      key: { id: id }
    }

    begin
      item = @dynamodb.get_item(params).item
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      raise "Unable to get token for id: #{id}"
    end

    item['expiration_time_millis'] = item['expiration_time_millis'].to_i

    return item.to_json
  end

  def delete(id)
    params = {
      table_name: 'GoogleTokens',
      key: { id: id }
    }

    begin
      @dynamodb.delete_item(params)
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      raise "Unable to delete token for id: #{id}"
    end
  end
end

def get_google_authorizer(dynamodb_connection)
  authorizer = nil
  exponential_backoff do
    client_id   = Google::Auth::ClientId.new(ENV['GOOGLE_OAUTH_CLIENT_ID'], ENV['GOOGLE_OAUTH_CLIENT_SECRET'])
    token_store = DynamoDBTokenStore.new(dynamodb_connection)
    authorizer  = Google::Auth::UserAuthorizer.new(client_id, GOOGLE_PERMISSION_SCOPES, token_store, 'https://tomcalendar.com')
  end
  authorizer
end

def get_session_id_from_cookies()
  session_id = TomEnv::get('HTTP_COOKIE')&.split(';')&.find{ |cookie| cookie.match?('session_id') }&.sub('session_id=','')&.strip
  return nil unless session_id
  return nil if session_id == ''
  return JSON.parse(session_id)
end

def refresh_tokens_and_cookie_session_id_is_valid?(cookie_session_id, time_zone=nil)
  return false unless cookie_session_id
  session_id = JSON.parse(cookie_session_id)

  cache_result = TomMemcache::get("refresh_tokens_and_cookie_session_id_is_valid?#{cookie_session_id}#{time_zone}").freeze
  return (cache_result.downcase == "true") if cache_result

  begin
    exponential_backoff do
      dynamodb = Aws::DynamoDB::Client.new(region: ENV['AWS_REGION'])

      params = {
        table_name: 'Sessions',
        key: session_id
      }

      item = dynamodb.get_item(params).item

      return false unless item
      google_authorizer = get_google_authorizer(dynamodb)
      google_credentials = google_authorizer.get_credentials(item['google_id'])
      google_credentials.refresh!
      return false if google_credentials.expired?

      # update the item
      item['last_updated'] = Time.now.to_s
      item['time_zone']    = time_zone

      session_params = {
        table_name: 'Sessions',
        item: item
      }

      dynamodb.put_item(session_params)
    end

    TomMemcache::set("refresh_tokens_and_cookie_session_id_is_valid?#{cookie_session_id}#{time_zone}", 'true', 60).freeze
    return true
  rescue Exception => e
    return false
  end
end

def calculate_time_passed_in_words(previous_time)
  seconds = Time.now - previous_time
  return '1 second ago' if seconds < 2
  return "#{seconds.to_i} seconds ago" if seconds < 60

  minutes = seconds / 60
  return '1 minute ago' if minutes < 2
  return "#{minutes.to_i} minutes ago" if minutes < 60

  hours = minutes / 60
  return '1 hour ago' if hours < 2
  return "#{hours.to_i} hours ago" if hours < 24

  days = hours / 24
  return '1 day ago' if days < 2
  return "#{days.to_i} days ago" if days < 365

  years = days / 365
  return '1 year ago' if years < 2
  return "#{years.to_i} years ago"
end

def exec_ruby_vm_code(file_path)
  if File.exist?(file_path)
    return RubyVM::InstructionSequence.load_from_binary( File.open(file_path, 'r').readlines.join('') ).eval
  else
    return RubyVM::InstructionSequence.load_from_binary( File.open(TomEnv::get('ROOT_DIR_PATH') + '/actions/not_found.rvmbin', 'r').readlines.join('') ).eval
  end
end

module TomMemcache
  # @remember single quotes in values will probably break this (can use $ to fix  ex) $'aa\'bb' will allow single quotes in value )
  def self.get(key)
    result = `tom_memcache_get '#{key}'`.freeze
    result = nil if (result == '')
    result
  end

  def self.set(key, value, expiration_in_seconds)
    `tom_memcache_set '#{key}' '#{value}' '#{expiration_in_seconds}'`
  end
end

$app_server_env = {}
class TomEnv
  def self.init_thread()
    $app_server_env[Thread.current.object_id] = {}
  end
  def self.get(key)
    return $app_server_env.fetch(Thread.current.object_id)&.fetch(key)
  end
  def self.set(key, value)
    return $app_server_env[Thread.current.object_id][key] = value
  end
end

def generate_is_reminder_set_hash(current_google_id, events)
  is_reminder_set_hash = {}
  return is_reminder_set_hash unless events && !events.empty?
  dynamodb  = Aws::DynamoDB::Client.new(region: ENV['AWS_REGION'])
  event_ids = events.map { |event| "#{event['google_id']}-#{event['title']}" }

  threads = []
  event_ids.each do |event_id| threads << Thread.new {
    begin
      last_evaluated_key ||= nil
      db_attempts ||= 0
      reminders_params = {
        table_name: 'EventReminders',
        key_condition_expression: "#sid = :subscriber_id AND #eid = :event_id",
        projection_expression: "event_id",
        expression_attribute_names: { "#sid" => "subscriber_id", "#eid" => "event_id" },
        exclusive_start_key: last_evaluated_key,
        expression_attribute_values: { ":subscriber_id" => current_google_id, ":event_id" => event_id }
      }

      query_result = dynamodb.query(reminders_params)
      query_result.items.each do |reminder|
        is_reminder_set_hash[reminder['event_id']] = true
      end
      if query_result.last_evaluated_key != last_evaluated_key
        last_evaluated_key = query_result.last_evaluated_key
      else
        last_evaluated_key = nil
      end
    rescue Exception => e
      if db_attempts < 3
        db_attempts = db_attempts + 1
        sleep 1
        retry
      else
        raise e
      end
    end
  } end
  threads.each(&:join)

  return is_reminder_set_hash
end

def create_google_calendar_events(events, google_calendar_id, google_id=nil)
  # https://developers.google.com/calendar/create-events
  # https://developers.google.com/calendar/v3/reference/events
  # https://tools.ietf.org/html/rfc5545#section-3.8.5
  # https://icalendar.org/rrule-tool.html

  # @remember: should limit image file size
  # @remember: should allow event to be from 11pm - 12am (maybe auto set to 11:59)

  if !google_id || (google_id == '') || (google_id == ' ')
    google_id = events[0]['google_id']
  end

  dynamodb              = Aws::DynamoDB::Client.new(region: ENV['AWS_REGION'])
  google_authorizer     = get_google_authorizer(dynamodb)
  service               = Google::Apis::CalendarV3::CalendarService.new
  service.authorization = google_authorizer.get_credentials(google_id)
  service.client_options.application_name = 'TomCalendar'.freeze

  events.each do |event|
    event_has_no_end = event['end_date'].nil? || (event['end_date'] == '') || (event['end_date'] == 'TBD')
    repeat_txt       = event['repeats']
    repeats_on_txt   = event['repeats_on']

    next if event['is_general_event']
    next unless event['start_date']
    next if (event['start_date'] == '') || (event['start_date'] == 'TBD')
    next if event['start_date'].split.length != 3  # requires month, date, and year
    unless event_has_no_end
      next if event['end_date'].split.length != 3
    end
    next if event_has_no_end && (repeat_txt == 'Does not repeat')

    start_date      = nil
    start_date_time = nil
    end_date        = nil
    end_date_time   = nil
    is_all_day      = false

    if event['start_time'] && (event['start_time'] != 'TBD') && (event['start_time'] != '')
      start_date_time = Time.parse("#{event['start_date']} #{event['start_time']}").xmlschema[0..18]
      end_date_time   = Time.parse("#{event['end_date']} #{event['end_time']}").xmlschema[0..18] unless event_has_no_end
    else
      start_date = Time.parse(event['start_date']).strftime("%Y-%m-%d")
      end_date   = Time.parse(event['end_date']).strftime("%Y-%m-%d") unless event_has_no_end
      is_all_day = true
    end

    next if !is_all_day && ( event['end_time'].nil? || (event['end_time'] == '') || (event['end_time'] == 'TBD') )

    if is_all_day && (repeat_txt == 'Does not repeat') && (event['start_date'] != event['end_date'])
      # 86400 seconds -> 1day
      end_date = ( Time.parse(event['end_date']) + 86400 ).strftime("%Y-%m-%d") unless event_has_no_end
    end

    rrule = nil
    unless repeat_txt == 'Does not repeat'
      frequency = 'DAILY'   if repeat_txt.include? 'day'
      frequency = 'WEEKLY'  if repeat_txt.include? 'week'
      frequency = 'MONTHLY' if repeat_txt.include? 'month'
      frequency = 'YEARLY'  if repeat_txt.include? 'year'

      interval = /\d\d\d|\d\d|\d/.match(repeat_txt).to_s
      interval = 1 if interval == ''

      rrule = "RRULE:FREQ=#{frequency};INTERVAL=#{interval}"

      case frequency
      when 'WEEKLY'
        rrule_on_days = []
        ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'].each do |weekday|
          if repeats_on_txt.include?(weekday) || repeats_on_txt.include?(weekday[0..2])
            rrule_on_days.push(weekday[0..1].upcase)
          end
        end
        rrule << ";BYDAY=#{rrule_on_days.join(',')}"
      when 'MONTHLY'
        if repeats_on_txt == 'On the same day each month'
          rrule_by_month_day = Time.parse(event['start_date']).strftime("%-d")
          rrule << ";BYMONTHDAY=#{rrule_by_month_day}"
        elsif (/\d/.match(repeats_on_txt))
          rrule_by_month_day = /\d/.match(repeats_on_txt).to_s
          ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'].each do |weekday|
            if repeats_on_txt.include?(weekday)
              rrule_by_month_day << weekday[0..1].upcase
              break
            end
          end
          rrule << ";BYDAY=#{rrule_by_month_day}"
        elsif repeats_on_txt == 'On the last day'
          rrule << ";BYMONTHDAY=28,29,30,31;BYSETPOS=-1"
        else # on last selected weekday
          ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'].each do |weekday|
            if repeats_on_txt.include?(weekday)
              rrule << ";BYDAY=-1#{weekday[0..1].upcase}"
              break
            end
          end
        end
      when 'YEARLY'
        rrule << ";BYMONTH=#{Time.parse(event['start_date']).strftime("%-m")};BYMONTHDAY=#{Time.parse(event['start_date']).strftime("%-d")}"
      end

      unless event_has_no_end
        if is_all_day
          until_date = Time.parse("#{event['end_date']} #{event['end_time'] || ''}").xmlschema[0..9].gsub('-','')
        else
          parsed_time = Time.parse("#{event['end_date']} #{event['end_time']}")
          until_date  = "#{TZInfo::Timezone.get(event['time_zone']).local_to_utc(parsed_time).xmlschema[0..18].gsub('-','').gsub(':','')}Z"
        end
        rrule << ";UNTIL=#{until_date}"
      end

      end_date_time = Time.parse("#{event['start_date']} #{event['end_time']}").xmlschema[0..18] unless is_all_day
      end_date      = start_date
    end

    google_event = Google::Apis::CalendarV3::Event.new(
      summary: event['title'],
      location: event['location'],
      description: event['description'],
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date: start_date,
        date_time: start_date_time,
        time_zone: event['time_zone']
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date: end_date,
        date_time: end_date_time,
        time_zone: event['time_zone']
      ),
      recurrence: [
        rrule
      ],
      extended_properties: { 'private': { 'tomcalendar_id': "#{event['google_id']}-#{event['title']}" } }
    )

    begin
      exponential_backoff do
        service.insert_event(google_calendar_id, google_event)
      end
    rescue Exception => e
      raise e
    end
  end
end

def delete_google_calendar_events(events, google_calendar_id, google_id=nil)
  # https://developers.google.com/calendar/create-events
  # https://developers.google.com/calendar/v3/reference/events
  # https://tools.ietf.org/html/rfc5545#section-3.8.5
  # https://icalendar.org/rrule-tool.html

  # @remember: should limit image file size
  # @remember: should allow event to be from 11pm - 12am (maybe auto set to 11:59)

  #events = JSON.parse(ARGV[0])
  #google_calendar_id = ARGV[1]
  #google_id = ARGV[2] || events[0]['google_id']
  if !google_id || (google_id == '') || (google_id == ' ')
    google_id = events[0]['google_id']
  end

  dynamodb              = Aws::DynamoDB::Client.new(region: ENV['AWS_REGION'])
  google_authorizer     = get_google_authorizer(dynamodb)
  service               = Google::Apis::CalendarV3::CalendarService.new
  service.authorization = google_authorizer.get_credentials(google_id)
  service.client_options.application_name = 'TomCalendar'.freeze

  events.each do |event|
    exponential_backoff do
      page_token = nil
      begin
        result = service.list_events(google_calendar_id, private_extended_property: "tomcalendar_id=#{event['google_id']}-#{event['title']}", page_token: page_token)
        result.items.each do |google_event|
          service.delete_event(google_calendar_id, google_event.id)
        end
        if result.next_page_token != page_token
          page_token = result.next_page_token
        else
          page_token = nil
        end
      end while !page_token.nil?
    end
  end
end

class BackgroundTask
  attr_accessor :name, :params

  def initialize(name, params)
    @name   = name
    @params = params
  end
end

$background_task_queue  = Queue.new
$background_task_params = {}  # thread safe as long as single worker thread and only used in tasks

def queue_background_task(task_name,param_hash)
  $background_task_queue << BackgroundTask.new(task_name,param_hash)
end

def background_task_worker_thread()
  while true do
    background_task = $background_task_queue.pop()
    $background_task_params = background_task.params

    begin
      exec_ruby_vm_code("#{ENV['ROOT_DIR_PATH']}/background_tasks/#{background_task.name}.rvmbin")
    rescue StandardError => e
      puts("Background Task: #{background_task.name} -> #{e.full_message}")
    end
  end
end

class Autocomplete
  # @remember: currently each server ip needs to be added to access policy
  @endpoint = ENV['ELASTICSEARCH_ENDPOINT'].freeze

  def self.add_user(user)
    user.transform_keys!(&:to_s)
    encoded_endpoint = "#{@endpoint}/users/_doc/#{CGI.escape(user['google_id'])}"
    `curl -XPUT --header 'Content-Type: application/json' '#{encoded_endpoint}' -d '#{user.to_json}'`
  end
  def self.add_event(event)
    event.transform_keys!(&:to_s)
    encoded_endpoint = "#{@endpoint}/events/_doc/#{CGI.escape(event['google_id'])}-#{CGI.escape(event['title'])}"
    `curl -XPUT --header 'Content-Type: application/json' '#{encoded_endpoint}' -d '#{event.to_json}'`
  end
  def self.delete_user(user)
    user.transform_keys!(&:to_s)
    encoded_endpoint = "#{@endpoint}/users/_doc/#{CGI.escape(user["google_id"])}"
    `curl -X DELETE '#{encoded_endpoint}'`
  end
  def self.delete_event(event)
    event.transform_keys!(&:to_s)
    encoded_endpoint = "#{@endpoint}/events/_doc/#{CGI.escape(event["google_id"])}-#{CGI.escape(event["title"])}"
    `curl -X DELETE '#{encoded_endpoint}'`
  end
  def self.search_users(username,from_index=0)
    JSON.parse(`curl -X POST --header 'Content-Type: application/json' #{@endpoint}/users/_search -d '{"size":"10", "from":"#{from_index}", "query":{"multi_match":{"fields":["email^2","name"],"fuzziness":"AUTO","query":"#{username}"}}}'`)["hits"]["hits"]
  end
  def self.search_events(event_title)
    JSON.parse(`curl -X POST --header 'Content-Type: application/json' #{@endpoint}/events/_search -d '{"size":"10", "from":"0", "query":{"multi_match":{"fields":["title^2","description"],"fuzziness":"AUTO","query":"#{event_title}"}}}'`)["hits"]["hits"]
  end
  def self.get_top_searched(limit)
    JSON.parse(`
      curl -X POST "#{@endpoint}/events,users/_search?size=#{limit}" -H 'Content-Type: application/json' -d '{
        "aggs": {
          "top_tags": {
            "terms": {
              "field": "type",
              "size": 3
            },
            "aggs": {
              "top_tom_hits": {
                "top_hits": {
                  "size": 1
                }
              }
            }
          }
        }
      }'
    `)["hits"]["hits"]
  end
end



# init background task thread (KEEP LAST LINE IN FILE)
Thread.new { background_task_worker_thread() }
