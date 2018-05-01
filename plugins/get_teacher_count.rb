require './canhelplib'

module CanhelpPlugin
  include Canhelp

  def self.get_teacher_count(canvas_url, account_id)
    token = get_token
    subaccount_ids = get_json_paginated(token, "#{canvas_url}/api/v1/accounts/#{account_id}/sub_accounts", "recursive=true").map{|s| s['id']}
    subaccount_ids << account_id

    puts "Grabbing enrollments from courses in the following accounts #{subaccount_ids}"

    all_teachers = []
    subaccount_ids.each do |subaccount_id|
      courses = get_json_paginated(token, "#{canvas_url}/api/v1/accounts/#{subaccount_id}/courses", "include[]=teachers")
      courses.each do |course|
        all_teachers.concat course['teachers']
      end
    end
    puts all_teachers.map{|t| t['id']}.uniq.count
  end
end
