require 'rubygems'

class ReporterIssueChangeListener < Redmine::Hook::Listener
  def controller_issues_bulk_edit_after_save(context={})
    controller_issues_edit_after_save(context)
  end
  def controller_issues_edit_after_save(context={})
    if !context[:params][:format] or 'xml' != context[:params][:format]
      if context[:issue] and context[:journal]
        Reporter.send_issue_update(User.current, context[:issue].id, context[:journal])
      end
    end
  end

  def controller_timelog_edit_before_save(context={})
    Reporter.send_time_log(User.current, context[:params], context[:time_entry])
  end

end