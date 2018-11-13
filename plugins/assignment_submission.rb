require './canhelplib'
require 'pry'
module CanhelpPlugin
  include Canhelp

  def create_submission(
      token,
      subdomain = prompt(:subdomain),
      course_id = prompt(:course_id),
      assignment_id = prompt(:assignment_id),
      user_id = prompt(:user_id)
      )
    canvas_url = "https://#{subdomain}.instructure.com"
    canvas_post("#{canvas_url}/api/v1/courses/#{course_id}/assignments/#{assignment_id}/submissions", token,
      {
      as_user_id: "#{user_id}",
      submission: {
        submission_type: "online_text_entry",
        body: "This is my submission - YAY!"
      }
    })
  end

  def self.student_submission(
    subdomain = prompt(:subdomain),
    course_id = prompt(:course_id),
    assignment_id = prompt(:assignment_id)
  )
    token = get_token
    canvas_url = "https://#{subdomain}.instructure.com"
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
          result = create_submission(token, subdomain, course_id, assignment_id, user_id)
          puts "user #{user_id} submitted to assignment #{assignment_id}"
        end
      end

    else
      user_ids.each do |user_id|
        binding.pry
        result = create_submission(token,subdomain, course_id, assignment_id, user_id)
        puts "user #{user_id} submitted to assignment #{assignment_id}"
      end
    end
  end
end
