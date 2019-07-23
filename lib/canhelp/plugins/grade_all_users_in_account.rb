require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp
  extend Actions

#grades all users in the course
#grades all assignments if assignment id is blank

  def self.grade_all_sub(
    subdomain: prompt(),
    subaccount_id: subaccount_id()
  )
    token = get_token
    canvas_url = "https://#{subdomain}.instructure.com"


    course_list = get_courses(subdomain,subaccount_id)

    course_ids = course_list.map do |c|
      c['id']
    end

    course_ids.each do | course_id |

      users = get_json_paginated(token, "#{canvas_url}/api/v1/courses/#{course_id}/users")
      puts "#{users.count} users found"
      user_ids = users.map do |user|
        user['id']
      end

      assignments = get_json_paginated(token, "#{canvas_url}/api/v1/courses/#{course_id}/assignments")
      assignments.each do |assignment|
        assignment_id = assignment['id']
        user_ids.each do |user_id|
          score = rand(10) + 5
          result = grade_submission(token, canvas_url, course_id, assignment_id, user_id, score)
          puts "User #{user_id} Grade for Assignment #{assignment_id}: #{score}"
        end
      end

    end
  end
end
