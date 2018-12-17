require '././canhelplib'
require 'csv'
require 'faker'
require_relative 'shared/actions.rb'

# create users.csv
# specify true or false to uplaod csv (sis import api)

require './canhelplib'
module CanhelpPlugin
  include Canhelp

  def self.csv_users(
    subdomain = prompt(:subdomain),
    user_count = prompt(:user_count),
    prefix = prompt(:prefix),
    user_type = prompt(:user_type),
    state = prompt(:state),
    sis_import = prompt(:sis_import_true_or_false)
  )
  token = get_token

  def parse_type(sis_import)
    case sis_import
    when 't'
      'true'
    when 'f'
      'false'
    else
      sis_import
    end
  end

  user_count = 1 if user_count.empty?

  print "Creating User(s)..."

    CSV.open("csv/users.csv",
      "wb",
      :write_headers=> true,
      :headers=>
      ['user_id','integration_id','login_id','password','ssha_password','authentication_provider_id','first_name','last_name','full_name','sortable_name','short_name','email','status']
    ) do |csv|
      user_count.to_i.times do |i|
        current_count = i + 1
        name = Faker::Name.name
        pseudonym = SecureRandom.hex(5)

        user_id= "#{user_type}_#{state}_#{prefix}#{current_count}#{pseudonym}_sis"
        login_id = "#{user_type}_#{state}_#{prefix}#{current_count}#{pseudonym}_login"
        password = "#{user_type}_#{state}_#{prefix}#{current_count}#{pseudonym}_login"
        full_name = "#{name}"
        email="aiona+#{user_type}_#{state}_#{prefix}#{current_count}#{pseudonym}@instructure.com"
        status = state

        csv << [user_id,nil,login_id,password,nil,nil,nil,nil,full_name,nil,nil,email,state]
        print "."
      end
    end

    if sis_import == "true"
      puts "\n"
      puts "Imported CSV file to #{subdomain}'s account."
      create_sis_import(subdomain)
    else
      puts "\n"
      puts "CSV created without importing."
    end

  end


end
