require_relative '../../canhelp'
require 'securerandom'
require 'pry'
require 'faker'
require 'date'
require 'csv'

module Actions
  extend Canhelp

  # Update course enrollments using token, canvas_url, course_id, enrollment_id, and state
  # random_state = ['conclude', 'delete', 'inactivate', 'deactivate'].sample(1)
  # delete using url, token, json body

  def update_enrollment(subdomain, course_id, enrollment_id, state)
    canvas_url = "https://#{subdomain}.instructure.com"
    token = get_token

    canvas_delete("#{canvas_url}/api/v1/courses/#{course_id}/enrollments/#{enrollment_id}",
    token,
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

  #get user enrollments
  def get_user_enrollments(subdomain,user_id,state)
    token = get_token
    canvas_url = "https://#{subdomain}.instructure.com"
    get_all_pages(token,
      "#{canvas_url}/api/v1/users/#{user_id}/enrollments?state[]=#{state}"
    )
  end

  #Add course to favorites
  def add_course_favorite(subdomain,course_id,user_id)
    token = get_token
    canvas_url = "https://#{subdomain}.instructure.com"
    response =
    canvas_post("#{canvas_url}/api/v1/users/self/favorites/courses/#{course_id}", token,{
      as_user_id: "#{user_id}"
      })
    puts "#{canvas_url}/api/v1/users/self/favorites/courses/#{course_id}?as_user_id=#{user_id}"
    puts response.body
  end

  #csv sis import
  def create_sis_import(subdomain,file)
    token = get_token
    canvas_url = "https://#{subdomain}.instructure.com"

    canvas_post_csv("#{canvas_url}/api/v1/accounts/self/sis_imports.json?import_type=instructure_csv",
      token,
      file
    )
  end

#get all sub_accounts in account specified
  def get_sub_accounts(subdomain,account_id)
    token = get_token
    subaccount_ids = get_all_pages(
      token,
      "https://#{subdomain}.instructure.com/api/v1/accounts/#{account_id}/sub_accounts?recursive=true").map{|s| s['id']}

  end

#get all courses in account id specified
  def get_courses (subdomain,subaccount_id)
    token = get_token
    courses = get_all_pages(
      token,
      "https://#{subdomain}.instructure.com/api/v1/accounts/#{subaccount_id}/courses"
      #needs to change for pageviews include[]=teachers&include[]=total_students&state[]=available&state[]=completed"
    )
  end

#get all section in course
  def get_sections (subdomain,course_id)
    token = get_token
    courses = get_all_pages(
      token,
      "https://#{subdomain}.instructure.com/api/v1/courses/#{course_id}/sections"
    )
  end

#create_submissions
def create_submission(token,subdomain,course_id,assignment_id,user_id)
  canvas_url = "https://#{subdomain}.instructure.com"
  canvas_post("#{canvas_url}/api/v1/courses/#{course_id}/assignments/#{assignment_id}/submissions", token,
    {
    as_user_id: "#{user_id}",
    submission: {
      submission_type: "online_text_entry",
      body: "This is my submission - YAY!"
    }
  })
end

def grade_submission(token, canvas_url, course_id, assignment_id, user_id, grade)
  canvas_put("#{canvas_url}/api/v1/courses/#{course_id}/assignments/#{assignment_id}/submissions/#{user_id}", token, {
    submission: {
      posted_grade: grade
    }
  })
end
#create users
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

  def create_enrollment(subdomain, course_id, user_id, type, state, self_enroll)
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
