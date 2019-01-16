require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp
  extend Actions

  def self.favorite_course(
    subdomain: prompt(),
    user_id: prompt(),
    state: prompt()
  )
    token = get_token
    current_count = 1
    canvas_url_api = "https://#{subdomain}.instructure.com/api/v1"
    failures = []
    checkmark = "\u2713"


    enrollment_list = get_user_enrollments(subdomain,user_id,state)

    course_ids = enrollment_list.map do |e|
      e['course_id']
    end

    course_ids.each do |course_id|
      #puts course_id
      add_course_favorite(subdomain,course_id,user_id)
    end
  end
end
