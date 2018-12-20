require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp

  def self.copy_course(
    subdomain: prompt(),
    source_course_id: prompt(),
    course_start: prompt(),
    course_end: prompt()
  )
    token = get_token

    (course_start..course_end).each do |course_id|
      api_url = "https://#{subdomain}.instructure.com/api/v1/courses/#{course_id}/course_copy"
      puts canvas_post(api_url, token,
        {
        source_course: source_course_id
        }
      )
    end
  end
end
