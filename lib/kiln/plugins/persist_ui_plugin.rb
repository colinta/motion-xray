module Kiln

  class PersistUIPlugin < Plugin
    name 'Save UI'

    class << self

      # @param format [Symbol] :teacup or :pixate
      # @param type [Class] The class that this encoder can handle
      # @block handler This block should accept an instance (of `type`) and return a string.
      def register(format, type, &handler)
        # don't care about the return - the side effect is to establish
        # @encoders
        encoders(format)[type] = handler
      end

      def encoders(format, type=nil)
        @encoders ||= {}
        @encoders[format] ||= {}
        unless @did_startup
          @did_startup = true
          startup
        end

        if type
          retval = nil
          while type
            retval = @encoders[format][type]
            break if retval
            type = type.superclass
          end
          return retval
        else
          return @encoders[format]
        end
      end

      def encode(format, object)
        handler = encoders(format, object.class)
        if handler
          handler.call(object)
        else
          nil
        end
      end

      def startup
        register(:teacup, CGRect) { |rect| "[[#{rect.origin.x}, #{rect.origin.y}], [#{rect.size.width}, #{rect.size.height}]]"}
        register(:teacup, CGPoint) { |rect| "[#{rect.origin.x}, #{rect.origin.y}]"}
        register(:teacup, CGSize) { |rect| "[#{rect.size.width}, #{rect.size.height}]"}
        register(:teacup, true.class) { |t| 'true' }
        register(:teacup, false.class) { |t| 'false' }
        # fall back
        register(:teacup, Object) { |v| v.inspect }
      end

    end

    def initialize
      # uiview instance => list of changes
      @changes = {}
    end

    def kiln_view_in(canvas)
      @log = UITextView.alloc.initWithFrame(canvas.bounds)
      @log.editable = false
      return @log
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
    end

    def kiln_edit(target)
      super
      KilnNotificationTargetDidChange.remove_observer(self)
      KilnNotificationTargetDidChange.add_observer(self, :'save_changes:', @target)
    end

    def show
      text = ''
      @changes.each do |view, properties|
        properties.each do |property, value|
          encoded = PersistUIPlugin.encode(:teacup, value)
          if encoded
            if @target.stylename
              text << "Teacup::Stylesheet[#{@target.stylesheet.name.inspect}].style #{view.stylename.inspect}, { #{property}: #{encoded}}\n"
            else
              text << "Teacup::Stylesheet[#{@target.stylesheet.name.inspect}].style #{view.class.name}, { #{property}: #{encoded}}\n"
            end
          end
        end
      end
      @log.text = text
    end

  end

end

