require './canhelplib'
require 'csv'

module CanhelpPlugin
  include Canhelp

  def self.get_teacher_count(
    canvas_url=prompt(:canvas_url),
    account_id=prompt(:account_id),
    teacher_role_id = prompt(:teacher_role_id)
  )
    token = get_token
    subaccount_ids = get_json_paginated(token, "#{canvas_url}/api/v1/accounts/#{account_id}/sub_accounts", "recursive=true").map{|s| s['id']}
    subaccount_ids << account_id

    puts "\t"
    puts "Grabbing enrollments from courses in the following accounts:"
    subaccount_ids.each do |subaccount|
      puts "- #{subaccount}"
    end

    all_teacher_enrollments = []

    subaccount_ids.each do |subaccount_id|
      courses = get_json_paginated(
        token,
        "#{canvas_url}/api/v1/accounts/#{subaccount_id}/courses",
        "include[]=teachers&include[]=total_students&state[]=available&state[]=claimed&state[]=created&state[]=completed"
      )

      courses.each do |course|
        course_ids = course['id']
        enrollments = get_json_paginated(
          token,
          "#{canvas_url}/api/v1/courses/#{course_ids}/enrollments",
          "state[]=active&state[]=completed&role[]=TeacherEnrollment"
        )

        course_name = course['name']
        course_state = course['workflow_state']
        total_students = course['total_students']

        puts
        puts "Course Name: #{course_name}"
        puts "- State: #{course_state}"
        puts "- Total number of students: #{total_students}"

        enrollments.each do |enrollment|
          if enrollment['role_id'].to_s == "#{teacher_role_id}"
            all_teacher_enrollments << enrollment

            teacher_name = enrollment['user']['name']

            puts "- Teacher's Name: #{teacher_name}"

          end
        end
      end
    end

    teacher_ids = all_teacher_enrollments.map { |enrollment|
      enrollment['user_id']
    }.uniq

    all_teacher_info = teacher_ids.map do |id|
      teacher_enrollment = all_teacher_enrollments.find { |enrollment|
        enrollment['user_id'] == id
      }
      next if teacher_enrollment.nil?

      [teacher_enrollment['user']['name'],teacher_enrollment['user_id'],teacher_enrollment['created_at'], teacher_enrollment['updated_at']]

    end.sort_by { |info_row| info_row[0].downcase }

    total_teacher_count = teacher_ids.count
    puts
    puts "Total number of TeacherEnrollments: #{total_teacher_count}"
    puts
    puts "All Teachers' Names: "
    CSV.open("../csv_help/csv/write_here.csv", "wb") do |csv|
      all_teacher_info.each do |info_row|
        csv << info_row
        #puts "- #{name}"
      end
    end
    puts "CSV done"
  end
end
