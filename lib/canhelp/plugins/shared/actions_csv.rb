require_relative '../../canhelp'
require 'securerandom'
require 'faker'
require 'csv'
require 'pry'
require 'date'

module Actions
  extend Canhelp

 #CSV open
  def csv_open(file_path, headers, &block)
    CSV.open(file_path, "wb", :write_headers => true, :headers => headers) do | csv|
      block.call csv
    end
  end

  #CSV read
  def csv_read(file_path)
    CSV.open(file_path, :headers => true).read
  end

  #create_user_csv
  def create_users_csv(
    subdomain,file_path,user_count,prefix,user_type,state,sis_import
  )
    headers =[
      'user_id','integration_id','login_id','password','ssha_password','authentication_provider_id','first_name','last_name','full_name','sortable_name','short_name','email','status'
    ]

    csv_open(file_path, headers) do |csv|
      user_count.to_i.times do |i|
        current_count = i + 1
        name = Faker::Name.name
        pseudonym = SecureRandom.hex(5)

        user_id= "#{user_type}_#{state}_#{prefix}#{current_count}#{pseudonym}_sis"
        login_id = "#{user_type}_#{state}_#{prefix}#{current_count}#{pseudonym}_login"
        password = "#{user_type}_#{state}_#{prefix}#{current_count}#{pseudonym}_login"
        full_name = "#{name}"
        email="aiona+#{user_type}_#{state}_#{prefix}#{current_count}#{pseudonym}@instructure.com"

        csv << [user_id,nil,login_id,password,nil,nil,nil,nil,full_name,nil,nil,email,state]
        puts user_id
      end
    end

    if truthy_response?(sis_import)
      puts "\n"
      puts "Imported #{user_type} User CSV file to #{subdomain}'s account."
      create_sis_import(subdomain,file_path)
    else
      puts "\n"
      puts "User CSV created without importing."
    end

  end

  #create users and enrollment csv
  def create_users_and_enrollments_csv(
    subdomain,section_ids,type_user_csv,type_enrollment_csv,user_count,prefix,role,state,sis_import
  )
    headers = [
      'course_id','root_account','start_date','end_date','user_id','user_integration_id','role','role_id','section_id','status','associated_user_id','limit_section_privileges'
    ]

    csv_open(type_enrollment_csv, headers) do |csv|
      puts "Created #{role}(s):"
      create_users_csv(subdomain,type_user_csv,user_count,prefix,role,state,sis_import)
      users_csv = csv_read(type_user_csv)
      user_sis_ids = p users_csv['user_id']

      user_sis_ids.each do |user_id|
        section_ids.each do |section_sis_id|
            csv << [nil,nil,nil,nil,user_id,nil,role,nil,section_sis_id,state,nil,nil]
            puts user_id
        end
      end
      puts "Creating #{role} enrollments..."
    end

    if truthy_response?(sis_import)
      puts "Imported #{role} Enrollment CSV file to #{subdomain}'s account."
      create_sis_import(subdomain,type_enrollment_csv)
    else
      puts "\n"
      puts "User and Enrollment CSV created without importing."
    end

  end

  def truthy_response?(sis_import)
    sis_import.match?(/t|true/)
  end

end
