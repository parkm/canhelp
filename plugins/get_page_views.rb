require './canhelplib'

module CanhelpPlugin
  include Canhelp

  def self.get_page_views_per_course(
    subdomain = prompt(:subdomain),
    course_id = prompt(:course_id),
    start_time = prompt(:start_time),
    end_time = prompt(:end_time)
  )

    token = get_token

    enrollments = get_json_paginated(
      token,
      "https://#{subdomain}.instructure.com/api/v1/courses/#{course_id}/enrollments",
      "state[]=active&state[]=completed&role[]=StudentEnrollment"
    )
    puts
    print "Total Number of StudentEnrollment: "
    puts enrollments.count
    puts

    with_page_views = []
    without_page_views = []

    enrollments.each do |enrollment|
      student_id =enrollment['user_id']
      student_name = enrollment['user']['name']

      print "Fetching Pageviews for #{student_name} #{student_id}: "
      page_views = get_all_pages(
        token,
        "https://#{subdomain}.instructure.com/api/v1/users/#{student_id}/page_views?start_time=#{start_time}&end_time=#{end_time}"
      )


      student_page_view = []

      student_page_view << page_views

      student_page_view.each do |page|
        if page.empty?
          puts "False"
          without_page_views << page
        else
          puts "True"
          with_page_views << page
        end

      end

    end

    puts
    puts "- Total count of users with Pageviews: #{with_page_views.count}"
    puts "- Total count of users with Pageviews: #{without_page_views.count}"
    puts

  end
end
