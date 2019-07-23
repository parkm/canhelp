require_relative '../canhelp'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  extend Canhelp
  extend Actions

  def self.create_modules_and_module_items(
    subdomain: prompt(),
    course_id: prompt(),
    count: prompt(),
    prefix: prompt(),
    score: prompt()
  )
    new_modules = create_module(subdomain,course_id,count,prefix)

    ###Completion requirement for this module item. “must_view”: Applies to all item types “must_contribute”: Only applies to “Assignment”, “Discussion”, and “Page” types “must_submit”, “min_score”: Only apply to “Assignment” and “Quiz” types Inapplicable types will be ignored

    #assignment_req= ['must_view', 'must_contribute', 'must_submit']
    # must_mark_done = assignments,pages,

    assignment_req= ['must_submit']
    quiz_req = ['must_view','must_submit']
    discussion_req = ['must_view','must_contribute']
    page_req = ['must_view','must_contribute']
    with_score=['min_score']

    # get list of mod ids
    modules = get_course_obj_list(subdomain,course_id,"modules")
    modules_count = modules.count

    # get list of assignments
    assignments = get_course_obj_list(subdomain,course_id,"assignments")
    assignments_count = assignments.count

    # number of assignments to add per module
    assignments_per_module = assignments_count/modules_count

    module_ids = []
    modules.each { |m| module_ids << m['id'] }

    assignment_ids = []
    assignments.each { |a| assignment_ids << a['id']}

    # for each module, add assignments_per_module
    module_ids.each do | mod |
      update_module(subdomain,course_id,mod)
      new_assignment_ids = assignment_ids.shift(assignments_per_module)
      new_assignment_ids.each do | a_id |

        #req = assignment_req.sample
        req = with_score.sample
        create_module_item_type(subdomain,course_id,mod,"Assignment",a_id,req,score)

        # create_module_item_score(subdomain,course_id,mod,"Assignment",a_id,score)
      end
    end

  end
end
