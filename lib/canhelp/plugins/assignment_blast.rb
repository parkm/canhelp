require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp
  extend Actions

  def self.assignment_blast(
    subdomain: prompt(),
    course_id: prompt(),
    count: prompt(),
    prefix: prompt()
  )
    token = get_token
    assignment_groups = get_assignment_groups(token,subdomain,course_id)

    #submissions = ['online_quiz','none','on_paper','discussion_topic','external_tool']
    submissions = ['none','on_paper','discussion_topic','external_tool','online_upload','online_text_entry','online_url','media_recording']


    submissions.each do | s |

      assignment_groups.each do |ag|
        group_id = ag['id']
        create_assignment(token,subdomain,course_id,count,prefix,group_id,s)
      end

    end

  end
end
