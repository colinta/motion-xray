module Kiln

  class PersistUIPlugin < Plugin
    name 'Save UI'

    def kiln_view_in(canvas)
    end

    def save_changes(notification)
      # notification.object
      # notification.userInfo['property']
      # notification.userInfo['value']
      NSLog("=============== persist_ui_plugin.rb line #{__LINE__} ===============
=============== #{self.class == Class ? self.name + '##' : self.class.name + '#'}#{__method__} ===============
notification.object: #{notification.object.inspect}
notification.userInfo['property']: #{notification.userInfo['property'].inspect}
notification.userInfo['value']: #{notification.userInfo['value'].inspect}")
    end

    def kiln_edit(editing)
      KilnNotificationTargetDidChange.remove_observer(self)
      KilnNotificationTargetDidChange.add_observer(self, :'save_changes:', @editing)
    end

  end

end

