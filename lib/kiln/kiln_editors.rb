module Kiln

  class Editor
    include Teacup::Layout

    attr_accessor :target
    attr_accessor :property

    class << self
      def with_target(target, property:property)
        self.new(target, property)
      end
    end

    def initialize(target, property)
      @target = target
      @property = property
    end

    def did_change?
      false
    end

    def get_edit_view(rect)
      @edit_view ||= self.edit_view(rect)
    end

    def did_change?
      true
    end

  end

  class PropertyEditor < Editor

    def initialize(target, property)
      super
      @original = get_value
    end

    def get_value
      target.send(property)
    end

    def set_value(value)
      target.send("#{property}=", value)
    end

    def did_change?
      ! CGRectEqualToRect(@original, @target.send(@property))
    end

  end

end
