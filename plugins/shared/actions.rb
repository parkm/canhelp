require '././canhelplib'
require 'securerandom'
require 'pry'
require 'faker'

module CanhelpPlugin
  include Canhelp

  def create_users(subdomain = nil, prefix = nil, count = nil)

    token = get_token
    canvas_url = "https://#{subdomain}.instructure.com"
    failures = []
    user_list = []
    user_id = []
    checkmark = "\u2713"

    print "Creating User(s)..."

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

        user_list << JSON.parse(response.body)

        if response.kind_of? Net::HTTPSuccess
          print "."
        else
          failures << response
          print "x"
        end

      end

#binding.pry

      #user_id = user_list.map { |user| user['id'] }

      user_list.each do |u|
        user_id << u['id']
      end

      user_count = user_id.count

#catch errors
      if failures.length > 0
        puts "Failures encountered"
        failures.each { |resp|
          puts "\n"
          puts "#{resp.code}: #{resp.message}"
          puts JSON.parse(response.body)
          puts "---------------------"
          puts "\n"
        }
      else
        puts "\n"
        puts "#{checkmark}Created #{user_count} User(s): #{user_id.to_s}"
        puts "\n"
      end

      return user_id

  end

# Grab course_enrollments
  # def update_enrollments(token, canvas_url, course_ids, enrollment_id)
  #   random_state = ['active', 'invited', 'inactive'].sample(1)
  #   canvas_put("#{canvas_url}/api/v1/courses/#{course_ids}/enrollments/#{enrollment_id}", token,
  #   {
  #
  #   }
  #   )
  #
  #
  # end
  #
  # def grab_enrollments (subdomain =nil, course_id = nil)
  #   token = get_token
  #   canvas_url = "https://#{subdomain}.instructure.com"
  #
  #   puts "Finding enrollments..."
  #
  #   enrollment_list = get_json_paginated(token,"#{canvas_url}/api/v1/#{course_id}/enrollments")
  #
  #   puts "#{enrollment_list.count} enrollments found."
  #
  #   enrollment_id = []
  #   enrollment_list.each do |e|
  #
  #   end
  #
  # end
# Enroll users

  def create_enrollments(subdomain=nil, course_id=nil, user_id=nil, type=nil, state = nil, self_enroll = false)

    token = get_token
    checkmark = "\u2713"
    canvas_url = "https://#{subdomain}.instructure.com"
    #random_state = ['active', 'invited', 'inactive'].sample(1)

    print "Creating Enrollment..."

    failures = []

    response = canvas_post("#{canvas_url}/api/v1/courses/#{course_id}/enrollments", token,
      {
        enrollment: {
        user_id: user_id,
        type: parse_type("#{type}"),
        enrollment_state: "#{state}",
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
        puts "\n"
        puts "#{resp.code}: #{resp.message}"
        puts JSON.parse(resp.body)
        puts "---------------------"
        puts "\n"
      }
    else
      puts "\n"
      puts "#{checkmark}Created an #{state} enrollment for user #{user_id} to course #{course_id}."
      puts "\n"
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
