require_relative '../canhelp'
require_relative 'shared/actions.rb'
require_relative 'create_user_and_enrollments.rb'

module CanhelpPlugin
  extend Canhelp
  extend Actions

#creates a course and 1 teacher and 5 students

  def self.enroll_automation_users(
    subdomain: prompt(),
    course_id: prompt(),
    teacher_id: prompt(),
    ta_id: prompt(),
    student_id: prompt(),
    observer_id: prompt(),
    designer_id: prompt(),
    other_role: prompt(),
    other_role_id: prompt(),
    self_enroll: prompt()
  )
    token = get_token
    checkmark = "\u2713"

    create_enrollment(subdomain,course_id,teacher_id,'TeacherEnrollment','active',self_enroll)
    create_enrollment(subdomain,course_id,ta_id,'TaEnrollment','active',self_enroll)
    create_enrollment(subdomain,course_id,student_id,'StudentEnrollment','active',self_enroll)
    create_enrollment(subdomain,course_id,observer_id,'ObserverEnrollment','active',self_enroll)
    create_enrollment(subdomain,course_id,designer_id,'DesignerEnrollment','active',self_enroll)
    create_enrollment(subdomain,course_id,other_role_id,other_role,'active',self_enroll)
  end

end
