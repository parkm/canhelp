require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp
  extend Actions

  def self.add_custom_data(
    subdomain: prompt(),
    account_id: prompt(),
    namespace: prompt(),
    data: prompt()
  )

  # grab all users in a specified account
  # using the user id, update their custom data

    users = get_users_in_account(subdomain,account_id)

    puts "Grabbing users"
    puts "Total users: #{users.count}"

    users.each do | u |
      id = u['id']
      puts "Adding custom data for user: #{id}"
      create_custom_data(subdomain,id,namespace,data)
    end

  end
end
