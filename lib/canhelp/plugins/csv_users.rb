require_relative '../canhelp'
require_relative 'shared/actions.rb'
require_relative 'shared/actions_csv.rb'
#require 'csv'
#require 'faker'

module CanhelpPlugin
  extend Canhelp
  extend Actions

  # create users.csv
  # specify true or false to uplaod csv (sis import api)

  def self.csv_users(
    subdomain: prompt(),
    user_count: prompt(),
    prefix: prompt(),
    user_type: prompt(),
    state: prompt(),
    sis_import: prompt()
  )
    token = get_token

    user_count = 1 if user_count.empty?
    file_path = "csv/users.csv"

    puts "Created User(s):"

    create_users_csv(subdomain,file_path,user_count,prefix,user_type,state,sis_import)
  end

end
