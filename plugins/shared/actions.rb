require '././canhelplib'
require 'securerandom'
require 'pry'
require 'faker'

module Actions
  include Canhelp

  # Update course enrollments using token, canvas_url, course_id, enrollment_id, and state
  # random_state = ['conclude', 'delete', 'inactivate', 'deactivate'].sample(1)
  # delete using url, token, json body

  def update_enrollment(subdomain, course_id, enrollment_id, state)
    canvas_url = "https://#{subdomain}.instructure.com"
    token = get_token

    canvas_delete("#{canvas_url}/api/v1/courses/#{course_id}/enrollments/#{enrollment_id}", token,
    {
      task: state
    }
    )
  end

  # Grab all course enrollments using subdomain, course_id
  # canvas_url using the subdomain given
  # puts "Finding enrollments..."
  # get enrollments via api
  # puts "#{course_enrollment.count} enrollment(s) found."
  # get enrollment id, and course id per enrollment
  # pass to update_enrollment (token, canvas_url, e['course_id'], e['id'], task = nil)

  # get_enrollments(token, subdomain, state: 'active')
  # def get_enrollments(token, url, options)
  #   url + "?state=#{options[:state]}" if options[:state]
  # end

  def get_enrollment (subdomain, course_id, state)
    token = get_token
    canvas_url = "#{subdomain}"

    puts "Finding enrollments..."

    course_enrollment = get_json_paginated(token,"#{canvas_url}/api/v1/courses/#{course_id}/enrollments")

    puts "#{course_enrollment.count} enrollment(s) found."

    course_enrollment

  end

  def get_sub_accounts(subdomain,account_id)
    token = get_token
    subaccount_ids = get_all_pages(
      token,
      "https://#{subdomain}.instructure.com/api/v1/accounts/#{account_id}/sub_accounts?recursive=true").map{|s| s['id']}

  end

  def get_courses (subdomain,subaccount_id)
    token = get_token
    courses = get_all_pages(
      token,
      "https://#{subdomain}.instructure.com/api/v1/accounts/#{subaccount_id}/courses"
      #needs to change for pageviews include[]=teachers&include[]=total_students&state[]=available&state[]=completed"
    )
  end

  def get_sections (subdomain,course_id)
    token = get_token
    courses = get_all_pages(
      token,
      "https://#{subdomain}.instructure.com/api/v1/courses/#{course_id}/sections"
    )
  end

  def create_user(subdomain, prefix, count, type, state)
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
          terms_of_use: true,
          skip_registration: true
        },

        pseudonym: {
          unique_id: "#{type}_#{state}_#{prefix}#{current_count}#{pseudonym}_login",
          password: "#{type}_#{state}_#{prefix}#{current_count}#{pseudonym}_login",
          sis_user_id: "#{type}_#{state}_#{prefix}#{current_count}#{pseudonym}_sis",
          send_confirmation: false,
          force_self_registration: false
        },

        communication_channel: {
          type: "email",
          address: "aiona+#{type}_#{state}_#{prefix}#{current_count}#{pseudonym}@instructure.com",
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

    user_list.each do |u|
      user_id << u['id']
    end

    user_count = user_id.count

    #Catch errors
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

    user_id
  end

  def create_enrollment(subdomain, course_id, section_id, user_id, type, state, self_enroll)
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
        self_enrolled: "#{self_enroll}",
        course_section_id: section_id
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
      puts "#{checkmark}Created #{state} enrollment for user #{user_id} to course #{course_id}."
      puts "\n"
    end

    #binding.pry

    JSON.parse(response.body)

  end


  def create_section_enrollment(subdomain, section_id, user_id, type, state, self_enroll)
    token = get_token
    checkmark = "\u2713"
    canvas_url = "https://#{subdomain}.instructure.com"
    #random_state = ['active', 'invited', 'inactive'].sample(1)

    print "Creating Section Enrollment..."

    failures = []

    response = canvas_post("#{canvas_url}/api/v1/sections/#{section_id}/enrollments", token,
      {
        enrollment: {
        user_id: user_id,
        type: parse_type("#{type}"),
        enrollment_state: "#{state}",
        self_enrolled: "#{self_enroll}",
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
      puts "#{checkmark}Created #{state} enrollment for user #{user_id} to section #{section_id}."
      puts "\n"
    end

    #binding.pry

    JSON.parse(response.body)

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
