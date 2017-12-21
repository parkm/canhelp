require '././canhelplib'
require 'securerandom'
require 'pry'
require 'faker'

module CanhelpPlugin
  include Canhelp

  def create_users(subdomain = nil, prefix = nil, count = nil)

    token = get_token
    canvas_url = "https://#{subdomain}.instructure.com"

    puts "Creating Users..."
    failures = []

    count.to_i.times do |i|
      current_count = i + 1
      name = Faker::Name.name
      pseudonym = SecureRandom.hex(5)
      response = canvas_post("#{canvas_url}/api/v1/accounts/self/users", token,
        {
          user: {
            name: "#{name}",
            short_name: "#{name}",
            sortable_name: "#{name}",
            terms_of_use: true,
            skip_registration: true
          },

          pseudonym: {
            unique_id: "#{prefix}#{current_count}#{pseudonym}_login",
            password: "#{prefix}#{current_count}#{pseudonym}_password",
            sis_user_id: "#{prefix}#{current_count}#{pseudonym}_sis",
            send_confirmation: false,
            force_self_registration: false
          },

          communication_channel: {
            type: "email",
            address: "aiona+#{prefix}#{current_count}#{pseudonym}@instructure.com",
            skip_confirmation: true
          },
          force_validation: true
        })

        if response.kind_of? Net::HTTPSuccess
          print "."
        else
          failures << response
          print "x"
        end
      end

#catch errors
      if failures.length > 0
        puts "Failures encountered"
        failures.each { |resp|
          puts "#{resp.code}: #{resp.message}"
          puts JSON.parse(resp.body)
          puts "---------------------"
        }
      else
        puts "Success! (draft - add enrollment count here)"
      end
  end


# Enroll users

  def create_enrollments(subdomain=nil, course_id=nil, user_id=nil, type=nil, state = nil, self_enroll = false)

    token = get_token
    canvas_url = "https://#{subdomain}.instructure.com"
    random_state = ['active', 'invited', 'inactive'].sample(1)

    puts "Creating Enrollments..."
    failures = []

    puts response = canvas_post("#{canvas_url}/api/v1/courses/#{course_id}/enrollments", token,
      {
        enrollment: {
        user_id: user_id,
        type: parse_type("#{type}"),
        enrollment_state: "#{state}" || "random_state",
        self_enrolled: "#{self_enroll}"
        }
      })

    if response.kind_of? Net::HTTPSuccess
      print "."
    else
      failures << response
      print "x"
    end

    if failures.length > 0
      puts "Failures encountered"
      failures.each { |resp|
        puts "#{resp.code}: #{resp.message}"
        puts JSON.parse(resp.body)
        puts "---------------------"
      }
    else
      puts "Success! Enrolled #{user_id}."
    end
  end

  private

  def parse_type(type)
    case type
    when 's'
      'StudentEnrollment'
    when 't'
      'TeacherEnrollment'
    when 'o'
      'ObserverEnrollment'
    when 'ta'
      'TaEnrollment'
    when 'd'
      'DesignerEnrollment'
    else
      type
    end
  end

end
