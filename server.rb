#!/usr/bin/env ruby
require 'webrick'
require 'json'

include WEBrick

class TimeZoneServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    response.status = 200
    response['Content-Type'] = 'application/json'
    time_hash = {"host_tz" => "#{Time.now.getlocal.zone}", "now" => "#{Time.now}", "utc" => "#{Time.now.getutc}", "host" => "#{Socket.gethostname}"}
    response.body = time_hash.to_json
  end
end
port = ENV['WEBRICK_PORT'] || '8080'

s = HTTPServer.new(
    :Port => port,
    :DocumentRoot => File.join(Dir.pwd)
)

trap("INT") { s.shutdown }

s.mount '/timezone', TimeZoneServlet
s.start
