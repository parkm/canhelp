require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp

  def self.create_test_course(
    subdomain = prompt(:subdomain),
    course_name = prompt(:course_name),
    user_prefix = prompt(:user_prefix),
    student_count = prompt(:student_count)
  )
    token = get_token
    checkmark = "\u2713"

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

    if response.kind_of? Net::HTTPSuccess
      print "#{checkmark} Course created\n"
    else
      failures << response
      print "Failed to create course"
      return
    end

    self.create_user_and_enrollment(subdomain, user_prefix, student_count, course_response['id'], [], 'StudentEnrollment', 'active', true)
    self.create_user_and_enrollment(subdomain, user_prefix, 1, course_response['id'], [], 'TeacherEnrollment', 'active', true)
  end
end
