require './canhelplib'

module CanhelpPlugin
  include Canhelp

  def self.get_student_count(canvas_url, account_id)
    token = get_token
    subaccount_ids = get_json_paginated(token, "#{canvas_url}/api/v1/accounts/#{account_id}/sub_accounts", "recursive=true").map{|s| s['id']}
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
      "include[]=total_students&include[]=teachers&state[]=created&state[]=claimed&state[]=available&state[]=completed&published=true"
      )

      courses.each do |course|
        course_ids = course['id']
        enrollments = get_json_paginated(
          token,
          "#{canvas_url}/api/v1/courses/#{course_ids}/enrollments",
          "state[]=active&state[]=completed&type[]=StudentEnrollment"
        )

        course_name = course['name']
        course_state = course['workflow_state']
        total_students = course['total_students']

        puts
        puts "Course Name: #{course_name}"
        puts "- State: #{course_state}"
        puts "- Total number of students: #{total_students}"

        enrollments.each do |enrollment|
          if enrollment['role_id'] == 3 #role_id: 3, 6
            all_student_enrollments << enrollment

            student_name = enrollment['user']['name']

            puts "- Students' Name: #{student_name}"

          end
        end
      end
    end

    student_ids = all_student_enrollments.map { |enrollment|
      enrollment['user_id']
    }.uniq

    all_student_info = student_ids.map do |id|
      student_enrollment = all_student_enrollments.find { |enrollment|
        enrollment['user_id'] == id
      }
      next if student_enrollment.nil?

      "#{student_enrollment['user']['name']} - #{student_enrollment['user_id']} | #{student_enrollment['created_at']} | #{student_enrollment['updated_at']}"
    end.sort_by(&:downcase)

    total_student_count = student_ids.count

    puts
    puts "Total number of StudentEnrollments: #{total_student_count}"
    puts
    puts "All Students' Names: "
    all_student_info.each do |name|
      puts "- #{name}"
    end
  end
end
