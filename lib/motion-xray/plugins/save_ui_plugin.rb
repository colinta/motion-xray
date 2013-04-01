module Motion ; module Xray

  class SaveUIPlugin < Plugin
    name 'Save UI'

    def initialize(type=nil)
      @type = type
    end

    def type
      @type || :teacup
    end

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
        register(:teacup, NSObject) { |v| v.inspect }
      end

    end

    def initialize
      # uiview instance => list of changes
      @changes = {}
    end

    def plugin_view(canvas)
      @log = UITextView.alloc.initWithFrame(canvas.bounds)
      @log.editable = false
      @log.font = :monospace.uifont
      @log.textColor = 0xBCBEAB.uicolor
      @log.backgroundColor = 0x2b2b2b.uicolor
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

    def edit(target)
      super
      XrayTargetDidChangeNotification.remove_observer(self)
      XrayTargetDidChangeNotification.add_observer(self, :'save_changes:', @target)
    end

    def show
      if type
        @log.text = send("#{type}_text")
      end
    end

    def teacup_text
      apply = {}
      @changes.each do |view, properties|
        properties.each do |property, value|
          encoded = SaveUIPlugin.encode(:teacup, value)
          if encoded
            apply[view] ||= []
            apply[view] << [property, encoded]
          end
        end
      end

      text = ''
      apply.each do |view, stuff|
        first_line = true
        if view.stylesheet && view.stylename
          name = "Teacup::Stylesheet[#{view.stylesheet.name.inspect}].style #{view.stylename.inspect},\n  "
        else
          name = "#{view.class.name.downcase}.style "
        end

        text << "#{name}"
        stuff.each do |property, encoded|
          unless first_line
            text << ",\n  "
          end
          text << "#{property}: #{encoded}"
          first_line = false
        end
        text << "\n\n"
      end
      return text
    end

  end

end end
