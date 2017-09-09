require './canhelplib'
module CanhelpPlugin
  include Canhelp

  def grade_submission(token, canvas_course_url, assignment_id, user_id, grade)
    uri = URI("#{canvas_course_url}/assignments/#{assignment_id}/submissions/#{user_id}")
    req = Net::HTTP::Put.new(uri)
    req['Content-Type'] = 'application/json'
    req['Authorization'] = "Bearer #{token}"
    req.body = ({
      submission: {
        posted_grade: grade
      }
    }).to_json

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    res = http.request(req)
  end

  def self.grade_all_users_in_course(canvas_course_url)
    token = get_token
    users = get_json_paginated(token, "#{canvas_course_url}/users?per_page=1000")
    puts "#{users.count} users found"
    user_ids = users.map do |user|
      user['id']
    end

    assignments = get_json(token, "#{canvas_course_url}/assignments?per_page=100")
    assignments.each do |assignment|
      assignment_id = assignment['id']
      user_ids.each do |user_id|
        result = grade_submission(token, canvas_course_url, assignment_id, user_id, '1')
        puts "graded #{assignment_id} for #{user_id} - #{result}"
      end
    end
  end
end
