require './canhelplib'
require 'date'

module CanhelpPlugin
  include Canhelp

  def self.course_last_activity(
    subdomain = prompt(:subdomain),
    course_id = prompt(:course_id)
  )

    token = get_token

    enrollments = get_json_paginated(
      token,
      "https://#{subdomain}.instructure.com/api/v1/courses/#{course_id}/enrollments",
      "state[]=active&state[]=completed&role[]=StudentEnrollment"
    )
    puts
    puts "Course ID: #{course_id}"
    print "Total Number of StudentEnrollment: "
    puts enrollments.count
    puts

    with_activity = []
    without_activity = []
    to = nil
    from = nil

    enrollments.each do |enrollment|
      student_id =enrollment['id']
      student_name = enrollment['user']['name']
      student_activity = enrollment['last_activity_at']

      print "Last Activity Date for #{student_name} (#{student_id}): "

      student_last_activity_dates = []

      student_last_activity_dates << student_activity

      student_last_activity_dates.each do |activity|
        d = DateTime.iso8601(activity)
        from = DateTime.iso8601('2018-04-16T00:00:00Z')
        to = DateTime.iso8601('2018-04-30T00:00:00Z')

        in_range = d > from && d < to
        out_of_range = d < from || d > to

        if activity == nil || out_of_range || !in_range
          puts activity
          without_activity << activity
        elsif
          d.between?(from,to)
          puts d
          with_activity << activity

        end
      end
    end

    puts
    puts "- Total count of users with activity between #{to} - #{from}: #{with_activity.count}"
    puts

  end
end
