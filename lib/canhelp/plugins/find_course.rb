require_relative '../canhelp'

module CanhelpPlugin
  include Canhelp

  def self.find_course(canvas_url)
    token = get_token
    courses = get_json(token, canvas_url + '/api/v1/courses')
    courses.each do |course|
      course['enrollments'].each do |enrollment|
        if enrollment['type'] == 'teacher'
          puts "#{course['id']} has a teacher"
        end
      end
    end
  end
end
