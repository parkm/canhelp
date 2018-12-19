require './canhelplib'
module CanhelpPlugin
  include Canhelp

  def self.publish_course_range(canvas_account_url, startId, endId)
    course_ids = (startId..endId).to_a.map do |id|
      id.to_s
    end
    puts "Publishing these courses: #{course_ids}"

    canvas_put("#{canvas_account_url}/courses", get_token, {
      "course_ids" => course_ids,
      event: 'offer'
    })
  end
end
