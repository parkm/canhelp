require './canhelplib'
module CanhelpPlugin
  include Canhelp

  def self.publish_course_range(canvas_account_url, startId, endId)
    uri = URI("#{canvas_account_url}/courses")
    req = Net::HTTP::Put.new(uri)
    req['Content-Type'] = 'application/json'
    req['Authorization'] = "Bearer #{get_token}"

    puts uri

    course_ids = (startId..endId).to_a.map do |id|
      id.to_s
    end
    puts "Publishing these courses: #{course_ids}"

    req.body = ({
      "course_ids" => course_ids,
      event: 'offer'
    }).to_json

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    res = http.request(req)
    puts res
  end
end
