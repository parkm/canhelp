require './canhelplib'
module CanhelpPlugin
  include Canhelp

  def self.copy_course(
    subdomain = prompt(:subdomain),
    source_course_id = prompt(:source_course_id),
    course_start = prompt(:course_start),
    course_end = prompt(:course_end)
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
