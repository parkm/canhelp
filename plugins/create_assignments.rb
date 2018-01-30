require './canhelplib'
require 'securerandom'

module CanhelpPlugin
  include Canhelp

  def self.create_assignments(
    subdomain = prompt(:subdomain),
    course_id = prompt(:course_id),
    count = prompt(:count),
    prefix = prompt(:prefix)
  )
    token = get_token
    current_count = 1
    canvas_url_api = "https://#{subdomain}.instructure.com/api/v1"
    failures = []
    checkmark = "\u2713"

    count.to_i.times do
      response = canvas_post("#{canvas_url_api}/courses/#{course_id}/assignments", token, {
        assignment: {
          name: "#{prefix} #{current_count}",
          submission_types: [
            "online_upload",
            "online_text_entry",
            "online_url",
            "media_recording"
          ],
          points_possible: 10,
          grading_type:"points",
          published:true,
        }
      })

      current_count += 1

      if response.kind_of? Net::HTTPSuccess
        print "#{checkmark}"
      else
        failures << response
        print "Failed to create assignment(s)."
        puts "\n"
      end

      if failures.length > 0
        puts "Failures encountered:"
        failures.each { |resp|
          puts "#{resp.code}: #{resp.message}"
          puts "\n"
          puts JSON.parse(resp.body)
          puts "\n"
          puts "---------------------"
        }
      else
        puts "\n"
        puts "Created #{count} asssignment(s) in course #{course_id}."
        puts "\n"
      end

    end
  end
end
