require_relative '../canhelp'
require_relative 'shared/actions.rb'
#require 'securerandom'

module CanhelpPlugin
  extend Canhelp

  def self.create_sections(
    subdomain = prompt(:subdomain),
    course_start = prompt(:course_start),
    course_end = prompt(:course_end),
    count = prompt(:count),
    prefix = prompt(:prefix)
  )
    token = get_token
    current_count = 1
    canvas_url_api = "https://#{subdomain}.instructure.com/api/v1"
    failures = []
    checkmark = "\u2713"


    (course_start..course_end).each do |course_id|
      count.to_i.times do
        response = canvas_post("#{canvas_url_api}/courses/#{course_id}/sections", token, {
          course_section: {
            name: "#{prefix} #{course_id} #{current_count}",
            sis_section_id: "#{prefix}_sis_#{course_id}_section_#{current_count}"
            #integration_id: "",
            #start_at: "",
            #end_at: "",
            #restrict_enrollments_to_section_dates: "",
          },
          enable_sis_reactivation: false
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
          puts "Created #{current_count} sections(s) in course #{course_id}."
          puts "\n"
        end

      end
    end

  end
end
