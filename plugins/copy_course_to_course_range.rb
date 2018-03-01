require './canhelplib'

# copy_course_to_course_range https://pmiller.instructure.com 1 50 100
# copies course 1 to course 50, 51, 52 ... 100

module CanhelpPlugin
  include Canhelp

  def self.copy_course_to_course_range(canvas_url, source_course_id, course_start, course_end)
    token = get_token

    (course_start..course_end).each do |course_id|
      api_url = "#{canvas_url}/api/v1/courses/#{course_id}/course_copy"
      puts canvas_post(api_url, token, {
        source_course: source_course_id
      })
    end
  end
end
