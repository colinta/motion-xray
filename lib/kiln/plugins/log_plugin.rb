module Kiln

  class LogPlugin < Plugin
    LogChangedNotification = 'Kiln::LogPlugin::LogChangedNotification'

    class << self
      def log
        @log ||= NSMutableAttributedString.alloc.initWithString('')
      end

      def add_log(type, args)
        message = sprintf(*args)
        case type
        when :log, :white
          nslog = "\033[37;4;1mLOG\033[0m  | #{message}"
          log_message = NSMutableAttributedString.alloc.initWithString("LOG", attributes: {
            NSForegroundColorAttributeName => 0xBCBEAB.uicolor,
            NSUnderlineStyleAttributeName => NSUnderlineStyleSingle,
          })
        when :error, :red
          nslog = "\033[31;4;1mERR\033[0m  | #{message}"
          log_message = NSMutableAttributedString.alloc.initWithString("ERR", attributes: {
            NSForegroundColorAttributeName => 0xCB7172.uicolor,
            NSUnderlineStyleAttributeName => NSUnderlineStyleSingle,
          })
        when :ok, :green
          nslog = "\033[32;4;1mO.K.\033[0m | #{message}"
          log_message = NSMutableAttributedString.alloc.initWithString("O.K.", attributes: {
            NSForegroundColorAttributeName => 0x60B48A.uicolor,
            NSUnderlineStyleAttributeName => NSUnderlineStyleSingle,
          })
        when :warning, :yellow
          nslog = "\033[33;4;1mWARN\033[0m | #{message}"
          log_message = NSMutableAttributedString.alloc.initWithString("WARN", attributes: {
            NSForegroundColorAttributeName => 0xDFAF8F.uicolor,
            NSUnderlineStyleAttributeName => NSUnderlineStyleSingle,
          })
        when :debug, :blue
          nslog = "\033[34;4;1mDEBG\033[0m | #{message}"
          log_message = NSMutableAttributedString.alloc.initWithString("DEBG", attributes: {
            NSForegroundColorAttributeName => 0x6B8197.uicolor,
            NSUnderlineStyleAttributeName => NSUnderlineStyleSingle,
          })
        when :notice, :magenta
          nslog = "\033[35;4;1mNOTE\033[0m | #{message}"
          log_message = NSMutableAttributedString.alloc.initWithString("NOTE", attributes: {
            NSForegroundColorAttributeName => 0xBB65A1.uicolor,
            NSUnderlineStyleAttributeName => NSUnderlineStyleSingle,
          })
        when :info, :cyan
          nslog = "\033[36;4;1mINFO\033[0m | #{message}"
          log_message = NSMutableAttributedString.alloc.initWithString("INFO", attributes: {
            NSForegroundColorAttributeName => 0x67AAAD.uicolor,
            NSUnderlineStyleAttributeName => NSUnderlineStyleSingle,
          })
        else
          raise "huh?"
        end

        NSLog(nslog)

        while log_message.length < 4
          log_message.appendAttributedString(NSAttributedString.alloc.initWithString(' '))
        end

        log_message.appendAttributedString(NSMutableAttributedString.alloc.initWithString(" | #{message}\n", attributes: {
          NSForegroundColorAttributeName => 0xBCBEAB.uicolor,
        }))

        log.appendAttributedString(log_message)
        LogChangedNotification.post_notification
      end
    end

    name 'Logs'

    def initialize
      super
      @text_view = nil
    end

    def kiln_view_in(canvas)
      @text_view = UITextView.alloc.initWithFrame(canvas.bounds).tap do |text_view|
        text_view.editable = false
        text_view.font = :monospace.uifont(12)
        text_view.backgroundColor = 0x2b2b2b.uicolor
      end
      update_log
      LogChangedNotification.add_observer(self, :'update_log:')
      return @text_view
    end

    def update_log(notification=nil)
      if @text_view
        # this can't be set in LogPlugin.add_log (font is not available during startup)
        log = NSMutableAttributedString.alloc.initWithAttributedString(LogPlugin.log)
        log.addAttribute(NSFontAttributeName, value: :monospace.uifont(10), range:NSRange.new(0, log.length))
        @text_view.attributedText = log
      end
    end

  end

  module Log
    module_function

    def _log(type, args)
      args = [''] if args == []
      LogPlugin.add_log(type, args)
    end

    def log(*args)
      Log._log(:log, args)
    end

    def error(*args)
      Log._log(:error, args)
    end

    def ok(*args)
      Log._log(:ok, args)
    end

    def warning(*args)
      Log._log(:warning, args)
    end
    def warn(*args)
      Log._log(:warning, args)
    end

    def debug(*args)
      Log._log(:debug, args)
    end

    def notice(*args)
      Log._log(:notice, args)
    end

    def info(*args)
      Log._log(:info, args)
    end
  end

end
