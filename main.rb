require 'csv'
require 'json'
require 'uri'
require 'net/http'

def fetch(uri_str, limit = 5)
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  url = URI.parse(uri_str)
  req = Net::HTTP::Get.new(url.to_s, { 'User-Agent' => 'Mozilla/5.0 (etc...)' })
  response = Net::HTTP.start(url.host, url.port, use_ssl: true) { |http| http.request(req) }
  case response
  when Net::HTTPSuccess     then response
  when Net::HTTPRedirection then fetch(response['location'], limit - 1)
  else
    response.error!
  end
end

export_url = "https://docs.google.com/spreadsheets/d/1lK6Bqv0hj0NG6eaKXwXVn24dKp77Qi0yYxXCrlw-xWk/export?format=csv&gid=0"

csv = CSV.parse(fetch(export_url).body, :headers => true)

headers = csv.headers

out = { 'events' => [] }

csv.each do |row|
  tmp = {}
  headers.each do |header|
    tmp[header] = row[header] unless row[header].nil?
  end
  out['events'] << tmp
end

puts JSON::dump(out)
