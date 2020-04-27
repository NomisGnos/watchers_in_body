module WatchersInBodyPlugin
  module WatchersInBodyMailHandlerPatch

    def self.included(base) # :nodoc:
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        alias_method :add_watchers_without_watchersinbody, :add_watchers
        alias_method :add_watchers, :add_watchers_with_watchersinbody
      end
    end
    
    # Adds To and Cc as watchers of the given object if the sender has the
    # appropriate permission
    def add_watchers_with_watchersinbody(obj)
      if handler_options[:no_permission_check] || user.allowed_to?("add_#{obj.class.name.underscore}_watchers".to_sym, obj.project)
        watcherslist = cleaned_up_text_body.match(/Watchers\: .*/)
        finalists = ''
        if watcherslist.nil? == false
          finalists = watcherslist[0].gsub /Watchers\: /, ""
          finalists = finalists.split(/\s*,\s*/)
        end
        addresses = [email.to, email.cc, finalists].flatten.compact.uniq.collect {|a| a.strip.downcase}
        unless addresses.empty?
          users = User.active.having_mail(addresses).to_a
          users -= obj.watcher_users
          users.each do |u|
            obj.add_watcher(u)
          end
        end
      end
    end

  end
end