require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp

#write how this works
  def update_grades(token, canvas_url, course_id, assignment_id, user_id, grade)
    canvas_post("#{canvas_url}/api/v1/courses/#{course_id}/assignments/#{assignment_id}/submissions/update_grades", token,
      {
        grade_data: {
        "#{user_id}" => { posted_grade: grade }
        }
      }
    )
  end

  def self.grade_all(
    canvas_url = prompt(:canvas_url),
    course_id = prompt(:course_id),
    assignment_id = prompt(:assignment_id)
  )
    token = get_token
    users = get_json_paginated(token, "#{canvas_url}/api/v1/courses/#{course_id}/users")
    puts "#{users.count} users found"
    user_ids = users.map do |user|
      user['id']
    end

    if assignment_id.empty?
      assignments = get_json_paginated(token, "#{canvas_url}/api/v1/courses/#{course_id}/assignments")
      assignments.each do |assignment|
        assignment_id = assignment['id']
        user_ids.each do |user_id|
          score = rand(10) + 5
          result = update_grades(token, canvas_url, course_id, assignment_id, user_id, score)
          puts "User #{user_id} grade for Assignment #{assignment_id}: #{score}"
        end
      end

    else
      user_ids.each do |user_id|
        score = rand(10) + 5
        result = update_grades(token, canvas_url, course_id, assignment_id, user_id, score)
        puts "User #{user_id} Grade for Assignment #{assignment_id}: #{score}"
      end
    end
  end
end
