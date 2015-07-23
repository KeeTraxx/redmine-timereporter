require 'redmine'
require_dependency 'time_entry_patch'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'time_entry'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless TimeEntry.included_modules.include? TimeEntryPatch
    TimeEntry.send(:include, TimeEntryPatch)
  end
end

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
