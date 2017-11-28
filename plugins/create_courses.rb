require './canhelplib'
require 'securerandom'

module CanhelpPlugin
  include Canhelp

  def self.create_courses(canvas_account_url, count, prefix)
    token = get_token
    current_count = 1

    count.to_i.times do
      canvas_post("#{canvas_account_url}/courses", token, {
        course: {
          name: "#{prefix} #{current_count}",
          course_code: "#{prefix} Code #{current_count}",
          sis_course_id: "#{prefix}_sis_#{current_count}"
        },
        offer: true,
        enroll_me: true
      })

      current_count += 1
    end
  end
end
