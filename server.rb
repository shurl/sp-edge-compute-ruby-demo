#!/usr/bin/env ruby
require 'webrick'
require 'json'
require 'net/http'

include WEBrick

$cached_ips = {}

class CachedIPServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    lookup_ip = if ['::1', 'localhost', '127.0.0.1'].include? request.remote_ip
                  '8.8.8.8'
                else
                  request.remote_ip
                end
    if $cached_ips.include? lookup_ip
      data = $cached_ips[lookup_ip]
      data['cache'] = 'HIT'
    else
      uri = URI('https://ipvigilante.com/' + lookup_ip)
      api_response = ''
      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: uri.scheme == 'https') do |http|
        api_request = Net::HTTP::Get.new uri
        api_response = http.request api_request
      end
      parsed = JSON.parse(api_response.body)
      $cached_ips[parsed['data']['ipv4']] = parsed['data']
      parsed['data']['cache'] = 'MISS'
      data = parsed['data']
    end
    response.status = 200
    response['Content-Type'] = 'application/json'
    response.body = data.to_json
  end
end
port = ENV['WEBRICK_PORT'] || '8080'

s = HTTPServer.new(
  Port: port,
  DocumentRoot: File.join(Dir.pwd)
)

trap('INT') { s.shutdown }

s.mount '/ip', CachedIPServlet
s.start
