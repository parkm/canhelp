require_relative '../canhelp'
require_relative 'shared/actions.rb'
#require 'securerandom'
#require 'faker'

module CanhelpPlugin
  extend Canhelp
  extend Actions

  #creates users and student and teacher enrollments in specified account
  #can only specify enrollment state job
  #create user per section
  #for each section, add enrollments based on teacher_count and student_count

  def self.enrollment_range(
      subdomain: prompt(),
      subaccount_id: prompt(),
      prefix: prompt(),
      teacher_count: prompt(),
      student_count: prompt(),
      state: prompt()
    )

    token = get_token

    teacher_count = 1 if teacher_count.empty?
    student_count = 1 if student_count.empty?
    student_type = 's'
    teacher_type = 't'
    student_enrollment_list = []
    teacher_enrollment_list = []

    course_list = get_courses(subdomain,subaccount_id)

    course_ids = course_list.map do |c|
      c['id']
    end

    section_hash = course_ids.reduce({}) do |memo, course_id|
      memo[course_id] = get_sections(subdomain,course_id).map do |section|
        section["id"]
      end
      memo
    end

    section_ids = section_hash.reduce([]) do |memo, mapping|
      memo.concat(mapping.last)
      memo
    end

    section_ids.each do |section_id|



      #students
      created_student_ids = create_user(
          subdomain,
          prefix,
          student_count,
          student_type,
          state
        )

        created_student_ids.each do |student|
          student_enrollment_list << create_section_enrollment(
            subdomain,
            section_id,
            student,
            student_type,
            state,
            self_enroll=nil
          )
        end

        #teachers
        created_teacher_ids = create_user(
          subdomain,
          prefix,
          teacher_count,
          teacher_type,
          state
        )

        created_teacher_ids.each do |teacher|
          teacher_enrollment_list << create_section_enrollment(
            subdomain,
            section_id,
            teacher,
            teacher_type,
            state,
            self_enroll=nil
          )
        end


    end
    #puts "Sections in Course #{section_hash}"
    puts "All section ids: #{section_ids}"
    puts "Courses in account:#{course_ids}"

  end
end
