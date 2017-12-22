require './canhelplib'
require 'securerandom'
require 'pry'
require 'faker'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  include Canhelp

  def self.create_user_and_enrollment (
    subdomain = prompt(:subdomain),
    prefix = prompt(:prefix),
    count= prompt(:count),
    course_id = prompt(:course_id),
    user_id = prompt(:user_id),
    type = prompt(:type),
    state = prompt(:state),
    self_enroll = prompt(:self_enroll)
  )

    created_user = create_users(subdomain, prefix, count)


    if user_id.empty?
      created_user.each do |u|
        #random_state = ['active', 'invited', 'inactive'].sample(1)
        create_enrollments(subdomain, course_id, u, type, state, self_enroll)
      end
    else
      create_enrollments(subdomain, course_id, user_id, type, state, self_enroll)
    end

  end
end
