require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp

  def self.publish_course_range(
     subdomain = prompt(:subdomain),
     startId = prompt(:startId),
     endId = prompt(:endId)
   )
    canvas_url = "https://#{subdomain}.instructure.com"
    course_ids = (startId..endId).to_a.map do |id|
      id.to_s
      canvas_put("#{canvas_url}/api/v1/courses/#{id}", get_token, {
        course:{
          event: 'offer'
        }
      })
      puts "Publishing course #{id}"
    end
  end
end
