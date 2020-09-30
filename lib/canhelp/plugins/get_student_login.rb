require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp

  def self.get_student_login(
    subdomain: prompt(),
    account_id: prompt(),
    student_role_id: prompt()
  )
    token = get_token
    canvas_url = "https://#{subdomain}.instructure.com"
    subaccount_ids = get_json_paginated(
      token, "#{canvas_url}/api/v1/accounts/#{account_id}/sub_accounts", "recursive=true"
    ).map{|s| s['id']}
    subaccount_ids << account_id

    puts "\t"
    puts "Grabbing enrollments from courses in the following accounts:"
    subaccount_ids.each do |subaccount|
      puts "- #{subaccount}"
    end

    all_student_enrollments = []

    subaccount_ids.each do |subaccount_id|
      courses = get_json_paginated(
      token,
      "#{canvas_url}/api/v1/accounts/#{subaccount_id}/courses",
      "include[]=total_students&include[]=teachers&state[]=available&state[]=completed"
      )

      courses.each do |course|
        if course['workflow_state'] != 'unpublished'
          course_ids = course['id']
          enrollments = get_json_paginated(
            token,
            "#{canvas_url}/api/v1/courses/#{course_ids}/enrollments",
            "state[]=active&state[]=completed&type[]=StudentEnrollment"
          )

          course_name = course['name']
          course_id = course['id']
          course_state = course['workflow_state']
          total_students = course['total_students']
          teacher_display_name = course['teachers']

          teacher_display_name.each do |teacher|
            teacher_name = teacher['display_name']
            puts
            puts "New Teacher's Name: #{teacher_name}"
            puts "Course ID: #{course_id}"
          end

          puts
          puts "New Course Name: #{course_name}"

          enrollments.each do |enrollment|
            if enrollment['role_id'].to_s == "#{student_role_id}"
              all_student_enrollments << enrollment

              course_id = enrollment['course_id']
              student_login = enrollment['user']['login_id']
              student_name = enrollment['user']['name']
              student_sis = enrollment['user']['sis_user_id']
              student_workflow_state = enrollment['enrollment_state']

              #puts "|  \'" + student_login + "\'" + " |  " + course_id + "  |"

              print "| \'"
              print student_login
              print "\' | "
              print course_id
              puts " |"

            end
          end
        end
      end
    end

    student_ids = all_student_enrollments.map { |enrollment|
      enrollment['user_id']
    }.uniq

    puts "Full List:"
    all_student_info = student_ids.map do |id|
      student_enrollment = all_student_enrollments.find { |enrollment|
        enrollment['user_id'] == id
      }
      next if student_enrollment.nil?

    student_login = student_enrollment['user']['login_id']
    course_id = student_enrollment['course_id']

    #puts "|  \'" + student_login + "\'" + " |  " + course_id + "  |"
    print "| \'"
    print student_login
    print "\' | "
    print course_id
    puts " |"

    end

    total_student_count = student_ids.count

    puts
    puts "Total number of active and completed StudentEnrollments: #{total_student_count}"
    puts
    puts "All Students' Names: "
    all_student_info.each do |name|
      puts "- #{name}"
    end
  end
end
