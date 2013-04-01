module Motion ; module Xray

  class Editor
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

    def get_edit_view(container_width)
      @edit_view ||= self.edit_view(container_width)
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
      if target.respond_to?(property)
        return target.send(property)
      elsif target.respond_to?("#{property}?")
        value = target.send("#{property}?")
        return target.send("#{property}?")
      end
    end

    def set_value(value)
      assign = "#{property}="
      setter = "set#{property.sub(/^./) { |c| c.upcase }}"

      if target.respond_to?(assign)
        target.send(assign, value)
      elsif target.respond_to?(setter)
        target.send(setter, value)
      end
      XrayTargetDidChangeNotification.post_notification(@target, { 'property' => @property, 'value' => value, 'original' => @original })
    end

  end

end end
