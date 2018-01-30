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
    create_users(subdomain,prefix,count)
    create_enrollments(subdomain, course_id, user_id, type, state, self_enroll)



  end

end
