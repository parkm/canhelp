require './canhelplib'
require 'securerandom'
require 'pry'
require 'faker'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  include Canhelp
  include Actions

  def self.create_module_prgression(
    subdomain = prompt(:subdomain),
    course_id = prompt(:course_id),
    user_id = prompt(:user_id),
  )

    mods = get_course_object_list(subdomain,course_id,"modules")

    mods_id = []
    mods.each do |m|
      mods_ids << m['id']
    end  

  end

end
