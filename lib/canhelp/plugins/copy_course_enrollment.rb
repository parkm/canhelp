require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp
  extend Actions

  def self.copy_course_enrollment(
    subdomain: prompt(),
    course_id_a: prompt(),
    course_id_b: prompt(),
    self_enroll: prompt()
  )

    list_enrollments = get_json(
      token,
      "https://#{subdomain}.instructure.com/api/v1/courses/#{course_id_a}/enrollments"
    )

    list_enrollments.each do | e |
      user_id = e['user_id']
      type = e['role']
      create_enrollment(subdomain,course_id_b,user_id,type,"active",self_enroll)
    end

  end
end
