require './canhelplib'
require 'securerandom'

module CanhelpPlugin
  include Canhelp

  def self.create_courses(
    subdomain = prompt(:subdomain),
    account_id = prompt(:account_id),
    count = prompt(:count),
    prefix = prompt(:prefix)
  )
    token = get_token
    current_count = 1
    canvas_url_api = "https://#{subdomain}.instructure.com/api/v1"
    failures = []
    checkmark = "\u2713"

    count.to_i.times do
      response = canvas_post("#{canvas_url_api}/accounts/#{account_id}/courses", token, {
        course: {
          name: "#{prefix} #{current_count}",
          course_code: "#{prefix} Course Code #{current_count}",
          sis_course_id: "#{prefix}_sis_#{current_count}"
        },
        offer: true,
        enroll_me: false
      })

      current_count += 1

      if response.kind_of? Net::HTTPSuccess
        print "#{checkmark}"
      else
        failures << response
        print "Failed to create course(s)."
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
        puts "Created #{count} course(s) in account #{account_id}."
        puts "\n"
      end

    end
  end
end
