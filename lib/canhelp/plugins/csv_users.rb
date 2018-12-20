require_relative '../canhelp'
require_relative 'shared/actions.rb'
require_relative 'shared/actions_csv.rb'
#require 'csv'
#require 'faker'

module CanhelpPlugin
  extend Canhelp

  # create users.csv
  # specify true or false to uplaod csv (sis import api)

  def self.csv_users(
    subdomain = prompt(:subdomain),
    user_count = prompt(:user_count),
    prefix = prompt(:prefix),
    user_type = prompt(:user_type),
    state = prompt(:state),
    sis_import = prompt(:sis_import_true_or_false)
  )
    token = get_token

    user_count = 1 if user_count.empty?
    file_path = "csv/users.csv"

    puts "Created User(s):"

    create_users_csv(subdomain,file_path,user_count,prefix,user_type,state,sis_import)
  end

end
