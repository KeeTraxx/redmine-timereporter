require 'redmine'
require_dependency 'reporter_issue_change_listener'
#require_dependency 'reporter_project_settings'

Redmine::Plugin.register :reporter do
  name 'Time reporter plugin'
  author 'Khôi Tran'
  description 'This plugin reports events to a REST backend.'
  version '1.0.1'
  url 'https://github.com/KeeTraxx/redmine-timereporter'
  author_url 'http://www.tran-engineering.ch'

  settings :default => {'callback_url' => 'https://debugserver.herokuapp.com/mycallback' },
           :partial => 'settings/reporter_settings'

end
