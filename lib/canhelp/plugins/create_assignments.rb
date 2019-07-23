require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp
  extend Actions

  def self.create_assignments(
    subdomain: prompt(),
    course_id: prompt(),
    count: prompt(),
    prefix: prompt()
  )
    token = get_token
    assignment_groups = get_assignment_groups(token,subdomain,course_id)
    online_submission = ["online_upload","online_text_entry","online_url","media_recording"]

    puts
    puts "Course ID: #{course_id}"
    print "Total Number of Assignment Groups:"
    puts assignment_groups.count
    puts

    assignment_groups.each do |ag|
      group_id = ag['id']
      create_assignment(token,subdomain,course_id,count,prefix,group_id,online_submission)
    end

  end
end
