module Kiln

  class PersistUIPlugin < Plugin
    name 'Save UI'

    def initialize
      # uiview instance => list of changes
      @changes = {}
    end

    def kiln_view_in(canvas)
    end

    def save_changes(notification)
      @changes[@target] ||= {}
      property = notification.userInfo['property']
      value = notification.userInfo['value']
      original = notification.userInfo['original']

      if value == original
        @changes[@target].delete(property)
      else
        @changes[@target][property] = notification.userInfo['value']
      end

      NSLog("=============== persist_ui_plugin.rb line #{__LINE__} ===============
=============== #{self.class == Class ? self.name + '##' : self.class.name + '#'}#{__method__} ===============
notification.object: #{notification.object.inspect}
property: #{property.inspect}
original: #{original.inspect}
value: #{value.inspect}
")
    end

    def kiln_edit(target)
      super
      KilnNotificationTargetDidChange.remove_observer(self)
      KilnNotificationTargetDidChange.add_observer(self, :'save_changes:', @target)
    end

  end

end

