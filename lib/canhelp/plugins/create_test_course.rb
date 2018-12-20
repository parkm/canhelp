require_relative '../canhelp'
require_relative 'shared/actions.rb'
require_relative 'create_user_and_enrollments.rb'

module CanhelpPlugin
  extend Canhelp
  extend Actions

#creates a course and 1 teacher and 5 students

  def self.create_test_course(
    subdomain: prompt(),
    course_name: prompt(),
    user_prefix: prompt()
  )
    token = get_token
    checkmark = "\u2713"
    student_count = 5
    teacher_count = 1

    response = canvas_post("https://#{subdomain}.instructure.com/api/v1/accounts/self/courses", token, {
      course: {
        name: course_name,
        course_code: course_name.split(' ').join('_'),
        sis_course_id: course_name.split(' ').join('_')
      },
      offer: true,
      enroll_me: false
    })

    course_response = JSON.parse(response.body)

    failures = []

    if response.kind_of? Net::HTTPSuccess
      print "#{checkmark} Course created\n"
    else
      failures << response
      print "Failed to create course"
      return
    end

    students = create_user(subdomain,"student_#{user_prefix}",student_count,'quick','active')
    teachers = create_user(subdomain,"teacher_#{user_prefix}",teacher_count,'quick','active')
    students.each do |student|
      create_enrollment(subdomain,course_response['id'],student,'StudentEnrollment','active',true)
    end

    teachers.each do |teacher|
      create_enrollment(subdomain,course_response['id'],teacher,'TeacherEnrollment','active',true)
    end

    # self.create_user_and_enrollment(subdomain, user_prefix, 10, course_response['id'], [], 'StudentEnrollment', 'active', true)
    # self.create_user_and_enrollment(subdomain, user_prefix, 1, course_response['id'], [], 'TeacherEnrollment', 'active', true)
  end
end
