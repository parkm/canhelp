require_relative '../canhelp'
require_relative 'shared/actions.rb'
#require 'securerandom'
#require 'faker'

module CanhelpPlugin
  extend Canhelp
  extend Actions

  #creates users and student and teacher enrollments in each enrollment state
  #can specify which course to add enrollments in

  def self.enrollment_blast(
    subdomain: prompt(),
    prefix: prompt(),
    teacher_count_per_state: prompt(),
    student_count_per_state: prompt(),
    course_id: prompt()
  )

  # student_total_count_per_state = 1
  # teacher_total_count_per_state = 1
    teacher_count_per_state = 1 if teacher_count_per_state.empty?
    student_count_per_state = 1 if student_count_per_state.empty?

    states = ['active', 'invited', 'delete', 'conclude', 'inactive']

    non_active = ['conclude', 'delete', 'inactivate', 'deactivate']

    states.each do |state|
      student_enrollment_list = []
      teacher_enrollment_list = []
      student_type = 's'
      teacher_type = 't'
      is_non_active = non_active.include? state

      if is_non_active
        effective_state = 'active'
      else
        effective_state = state
      end

      #students

      created_student_ids = create_user(
        subdomain,
        prefix,
        student_count_per_state,
        student_type,
        state
      )

      created_student_ids.each do |student|
        student_enrollment_list << create_enrollment(
          subdomain,
          course_id,
          student,
          student_type,
          effective_state,
          self_enroll=nil
        )
      end

      #teachers

      created_teacher_ids = create_user(
        subdomain,
        prefix,
        teacher_count_per_state,
        teacher_type,
        state
      )

      created_teacher_ids.each do |teacher|
        teacher_enrollment_list << create_enrollment(
          subdomain,
          course_id,
          teacher,
          teacher_type,
          effective_state,
          self_enroll=nil
        )
      end


      if is_non_active

        #students
        puts "Setting StudentEnrollment(s) to #{effective_state}..."

        student_enrollment_list.each do |studentenrollment|
          update_enrollment(
            subdomain,
            studentenrollment['course_id'],
            studentenrollment['id'],
            state
          )
          print "."
        end

        #teachers
        puts "Setting TeacherEnrollment(s) to #{effective_state}..."

        teacher_enrollment_list.each do |teacherenrollment|
          update_enrollment(
            subdomain,
            teacherenrollment['course_id'],
            teacherenrollment['id'],
            state
          )
          print "."
        end

      end

      puts
      puts "Done."
    end
  end
end
