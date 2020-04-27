require 'redmine'

Redmine::Plugin.register :watchers_in_body do
  name 'Watchers in Body plugin'
  author 'Simon Song <sys106@psu.edu>'
  description 'This plugin will allow watchers be added from the email\'s body via regex.  It adds watchers when it finds emails from "Watchers: " . Works with Rail 5+'
  version '1.0.0'
  url 'http://github.com/nomisgnos'
  author_url 'http://harrisburg.psu.edu'
end

receiver = Object.const_defined?('ActiveSupport::Reloader') ?  ActiveSupport::Reloader : ActionDispatch::Callbacks
receiver.to_prepare  do
  require_dependency 'mail_handler'

  MailHandler.send(:include, WatchersInBodyPlugin::WatchersInBodyMailHandlerPatch)
end

require 'wib_mail_handler_patch.rb'
