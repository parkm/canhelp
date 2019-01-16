require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp

  def self.create_courses(
    subdomain: prompt(),
    account_id: prompt(),
    term: prompt(),
    count: prompt(),
    prefix: prompt()
  )
    token = get_token
    current_count = 1
    canvas_url_api = "https://#{subdomain}.instructure.com/api/v1"
    failures = []
    checkmark = "\u2713"

    count.to_i.times do
      course_sis_id = "#{prefix}_sis_#{current_count}"
      response = canvas_post("#{canvas_url_api}/accounts/#{account_id}/courses", token, {
        course: {
          name: "#{prefix} #{current_count}",
          course_code: "#{prefix} Course Code #{current_count}",
          sis_course_id: course_sis_id.gsub(/\s+/, ""),
          term_id: "#{term}"
        },
        offer: true, #publish or unpublish
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
        puts "Created #{current_count} course(s) in account #{account_id}."
        puts "\n"
      end

    end
  end
end
