require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp

  def self.one_account_page_view(
    subdomain: prompt(),
    account_id: prompt(),
    start_time: prompt(),
    end_time: prompt()
  )

    token = get_token

    subaccount_ids = get_sub_accounts(subdomain,account_id)

    subaccount_ids << account_id

    puts "\t"
    puts "Comparing course account_ids in the following accounts:"

    with_page_views = []
    without_page_views = []
    student_page_views = []

    subaccount_ids.each do |subaccount_id|
      puts "- #{subaccount_id}"
    end

    subaccount_ids.each do |subaccount|
      courses = get_courses(subdomain, subaccount)

      courses.each do |course|
        course_ids = course['id']
        course_account_id = course['account_id']

        if course_account_id == account_id.to_i

          enrollments = get_all_pages(
            token,
            "https://#{subdomain}.instructure.com/api/v1/courses/#{course_ids}/enrollments?state[]=active&state[]=completed&type[]=StudentEnrollment"
          )

          puts
          print "Total Number of StudentEnrollment: "
          puts enrollments.count
          puts

          enrollments.each do |enrollment|
            student_id =enrollment['user_id']
            student_name = enrollment['user']['name']

            print "Fetching Pageviews for #{student_name} #{student_id}: "
            page_views = get_json(
              token,
              "https://#{subdomain}.instructure.com/api/v1/users/#{student_id}/page_views?start_time=#{start_time}&end_time=#{end_time}"
            )

              if page_views.empty?
                puts "False"
                without_page_views += page_views
              else
                puts "True"
                with_page_views += page_views
              end

            end

          end

        end

    end

    unique_users_with_page_views = with_page_views.map { |user_page_view| user_page_view['links']['user']
    }.uniq

    puts
    puts "- Total count of users with Pageviews: #{unique_users_with_page_views.count}"
    puts "-- #{unique_users_with_page_views}"
    puts "- Total count of users without Pageviews: #{without_page_views.count}"

  end
end
