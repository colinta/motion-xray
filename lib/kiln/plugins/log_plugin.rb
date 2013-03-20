module Kiln

  class LogPlugin < Plugin
    LogChangedNotification = 'Kiln::LogPlugin::LogChangedNotification'

    class << self
      def log
        @log ||= []
      end

      def add_log(type, args)
        message = sprintf(*args)
        case type
        when :log, :white
          nslog = "\033[37m#{message}\033[0m"
          log_message = NSMutableAttributedString.alloc.initWithString("#{message}\n", attributes: {
            NSForegroundColorAttributeName => 0xBCBEAB.uicolor,
          })
        when :error, :red
          nslog = "\033[31;4;1mERROR!\033[0m\033[31m #{message}\033[0m"
          log_message = NSMutableAttributedString.alloc.initWithString("ERROR! #{message}\n", attributes: {
            NSForegroundColorAttributeName => 0xCB7172.uicolor,
          })
        when :ok, :green
          nslog = "\033[32m#{message}\033[0m"
          log_message = NSMutableAttributedString.alloc.initWithString("#{message}\n", attributes: {
            NSForegroundColorAttributeName => 0x60B48A.uicolor,
          })
        when :warning, :yellow
          nslog = "\033[33m#{message}\033[0m"
          log_message = NSMutableAttributedString.alloc.initWithString("#{message}\n", attributes: {
            NSForegroundColorAttributeName => 0xDFAF8F.uicolor,
          })
        when :debug, :blue
          nslog = "\033[34m#{message}\033[0m"
          log_message = NSMutableAttributedString.alloc.initWithString("#{message}\n", attributes: {
            NSForegroundColorAttributeName => 0x6B8197.uicolor,
          })
        when :notice, :magenta
          nslog = "\033[35m#{message}\033[0m"
          log_message = NSMutableAttributedString.alloc.initWithString("#{message}\n", attributes: {
            NSForegroundColorAttributeName => 0xBB65A1.uicolor,
          })
        when :info, :cyan
          nslog = "\033[36m#{message}\033[0m"
          log_message = NSMutableAttributedString.alloc.initWithString("#{message}\n", attributes: {
            NSForegroundColorAttributeName => 0x67AAAD.uicolor,
          })
        else
          raise "huh?"
        end

        NSLog(nslog)

        log << {message:log_message, date:NSDate.new}
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
        text_view.delegate = self
        text_view.backgroundColor = 0x2b2b2b.uicolor
      end

      @toggle_button = UIButton.alloc.initWithFrame([[0, 0], [7, 259]])
      @toggle_button.setImage('kiln_open_drawer'.uiimage, forState: :normal.uicontrolstate)
      @toggle_button.on :touch {
        toggle_datetimes
      }

      @showing_datetimes = false
      return UIView.alloc.initWithFrame(canvas.bounds).tap do |view|
        view << @text_view
        view << @toggle_button
        view.backgroundColor = 0x2b2b2b.uicolor
      end
    end

    def toggle_datetimes
      if @showing_datetimes
        hide_datetimes
      else
        show_datetimes
      end
    end

    def show_datetimes
      return if @showing_datetimes
      @showing_datetimes = true
      @toggle_button.setImage('kiln_close_drawer'.uiimage, forState: :normal.uicontrolstate)
      update_log
    end

    def hide_datetimes
      return unless @showing_datetimes
      @showing_datetimes = false
      @toggle_button.setImage('kiln_open_drawer'.uiimage, forState: :normal.uicontrolstate)
      update_log
    end

    def show
      LogChangedNotification.add_observer(self, :'update_log:')
      update_log
    end

    def hide
      LogChangedNotification.remove_observer(self)
    end

    def update_log(notification=nil)
      if @text_view
        log = NSMutableAttributedString.alloc.init
        LogPlugin.log.each do |msg|
          if @showing_datetimes
            date = msg[:date].string_with_format(:iso8601)
            log.appendAttributedString(NSMutableAttributedString.alloc.initWithString("#{date} ", attributes: {
              NSForegroundColorAttributeName => 0xBCBEAB.uicolor,
            }))
          end
          log.appendAttributedString(msg[:message])
        end
        # this can't be set in LogPlugin.add_log (font is not available during startup)
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
