require './canhelplib'

# create_assignment_groups_for_course_range https://pmiller.instructure.com 6 mygroups 50 100
# creates 6 assignment groups for courses 50, 51, 52 ... 100

module CanhelpPlugin
  include Canhelp

  def self.create_assignment_groups_for_course_range(canvas_url, group_count, group_prefix, course_start, course_end)
    token = get_token

    group_weight = 100 / group_count.to_i
    (course_start..course_end).each do |course_id|
      api_url = "#{canvas_url}/api/v1/courses/#{course_id}/assignment_groups"
      group_count.to_i.times do |i|
        puts canvas_post(api_url, token, {
          name: "#{group_prefix} #{i+1}",
          group_weight:  group_weight
        })
      end
    end
  end
end
