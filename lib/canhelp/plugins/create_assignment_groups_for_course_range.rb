require_relative '../canhelp'
require_relative 'shared/actions.rb'

# create_assignment_groups_for_course_range https://pmiller.instructure.com 6 mygroups 50 100
# creates 6 assignment groups for courses 50, 51, 52 ... 100

module CanhelpPlugin
  extend Canhelp

  def self.create_assignment_groups_for_course_range(
    subdomain: prompt(),
    group_count: prompt() ,
    group_prefix: prompt(),
    course_start: prompt(),
    course_end: prompt()
  )

    token = get_token
    canvas_url = "https://#{subdomain}.instructure.com"

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
