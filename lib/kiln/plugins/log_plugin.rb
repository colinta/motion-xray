module Kiln

  class LogPlugin < Plugin
    LogChangedNotification = 'Kiln::LogPlugin::LogChangedNotification'

    class << self
      def log
        @log || clear!
      end

      def clear!
        @log = []
      end

      def add_log(type, args)
        message = sprintf(*args)
        case type
        when :error, :red
          nslog = "\033[31;4;1mERROR!\033[0m\033[31m #{message}\033[0m"
          log_message = NSMutableAttributedString.alloc.initWithString("ERROR! #{message}\n", attributes: {
            NSForegroundColorAttributeName => 0xCB7172.uicolor,
          })
        when :warning, :yellow
          nslog = "\033[33m#{message}\033[0m"
          log_message = NSMutableAttributedString.alloc.initWithString("#{message}\n", attributes: {
            NSForegroundColorAttributeName => 0xDFAF8F.uicolor,
          })
        when :log, :white
          nslog = "\033[37m#{message}\033[0m"
          log_message = NSMutableAttributedString.alloc.initWithString("#{message}\n", attributes: {
            NSForegroundColorAttributeName => 0xBCBEAB.uicolor,
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
        when :ok, :green
          nslog = "\033[32m#{message}\033[0m"
          log_message = NSMutableAttributedString.alloc.initWithString("#{message}\n", attributes: {
            NSForegroundColorAttributeName => 0x60B48A.uicolor,
          })
        when :debug, :blue
          nslog = "\033[34m#{message}\033[0m"
          log_message = NSMutableAttributedString.alloc.initWithString("#{message}\n", attributes: {
            NSForegroundColorAttributeName => 0x6B8197.uicolor,
          })
        else
          raise "huh?"
        end

        if Log.level >= Log::Levels[type]
          NSLog(nslog)
        end

        entry = {message:log_message, date:NSDate.new}
        log << entry
        LogChangedNotification.post_notification(nil, entry)
      end
    end

    name 'Logs'
    ActionsWidth = 25

    def kiln_view_in(canvas)
      @text_view = UITextView.alloc.initWithFrame(canvas.bounds).tap do |text_view|
        text_view.editable = false
        text_view.delegate = self
        text_view.backgroundColor = 0x2b2b2b.uicolor
      end

      @toggle_datetimes_button = UIButton.alloc.initWithFrame([[0, 0], [7, 259]])
      @toggle_datetimes_button.setImage('kiln_drawer_right'.uiimage, forState: :normal.uicontrolstate)
      @toggle_datetimes_button.on :touch {
        toggle_datetimes
      }

      @toggle_actions_button = UIButton.alloc.initWithFrame([[0, 0], [7, 259]])
      @toggle_actions_button.setImage('kiln_drawer_left'.uiimage, forState: :normal.uicontrolstate)
      @toggle_actions_button.on :touch {
        toggle_actions
      }

      btn_width = @toggle_actions_button.frame.width
      actions_frame = [[canvas.bounds.width - btn_width, 0], [ActionsWidth + btn_width, 259]]
      @actions_container = UIView.alloc.initWithFrame(actions_frame).tap do |actions_container|
        button_y = 0
        clear_button = UIButton.custom
        clear_button.setImage('kiln_clear_button'.uiimage, forState: :normal.uicontrolstate)
        clear_button.frame = [[@toggle_actions_button.frame.width, button_y], [ActionsWidth, ActionsWidth]]
        clear_button.on :touch {
          LogPlugin.clear!
          update_log
        }
        actions_container << clear_button
        button_y += ActionsWidth

        # send email button
        if MFMailComposeViewController.canSendMail
          email_button = UIButton.custom
          email_button.setImage('kiln_email_button'.uiimage, forState: :normal.uicontrolstate)
          email_button.frame = [[@toggle_actions_button.frame.width, button_y], [ActionsWidth, ActionsWidth]]
          email_button.on :touch {
            mail_view_controller = MFMailComposeViewController.new
            mail_view_controller.mailComposeDelegate = self
            mail_view_controller.setSubject('From kiln.')
            mail_view_controller.setMessageBody(LogPlugin.log.map{ |line| line[:message].string }.join("\n"), isHTML:false)
            Kiln.cool_down
            present_modal mail_view_controller
          }
          actions_container << email_button
          button_y += ActionsWidth
        end
      end
      @actions_container << @toggle_actions_button

      @showing_datetimes = false
      @showing_actions = false
      return UIView.alloc.initWithFrame(canvas.bounds).tap do |view|
        view << @text_view
        view << @toggle_datetimes_button
        view << @actions_container
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
      @toggle_datetimes_button.setImage('kiln_drawer_left'.uiimage, forState: :normal.uicontrolstate)
      update_log
    end

    def hide_datetimes
      return unless @showing_datetimes

      @showing_datetimes = false
      @toggle_datetimes_button.setImage('kiln_drawer_right'.uiimage, forState: :normal.uicontrolstate)
      update_log
    end

    def toggle_actions
      if @showing_actions
        hide_actions
      else
        show_actions
      end
    end

    def show_actions
      return if @showing_actions

      @showing_actions = true
      @toggle_actions_button.setImage('kiln_drawer_right'.uiimage, forState: :normal.uicontrolstate)
      @actions_container.slide(:left, size: ActionsWidth, options: UIViewAnimationOptionCurveLinear)
      @text_view.frame = @text_view.frame.thinner(ActionsWidth)
    end

    def hide_actions
      return unless @showing_actions

      @showing_actions = false
      @toggle_actions_button.setImage('kiln_drawer_left'.uiimage, forState: :normal.uicontrolstate)
      @actions_container.slide(:right, size: ActionsWidth, options: UIViewAnimationOptionCurveLinear)
      @text_view.frame = @text_view.frame.wider(ActionsWidth)
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
        if notification
          log.appendAttributedString(@text_view.attributedText)
          append_entry(log, notification.userInfo)
        else
          LogPlugin.log.each do |msg|
            append_entry(log, msg)
          end
        end
        # this can't be set in LogPlugin.add_log (font is not available during startup)
        log.addAttribute(NSFontAttributeName, value: :monospace.uifont(10), range:NSRange.new(0, log.length))
        @text_view.attributedText = log
      end
    end

    def append_entry(log, entry)
      if @showing_datetimes
        date = entry[:date].string_with_format(:iso8601)
        log.appendAttributedString(NSMutableAttributedString.alloc.initWithString("#{date} ", attributes: {
          NSForegroundColorAttributeName => 0xBCBEAB.uicolor,
        }))
      end
      log.appendAttributedString(entry[:message])
    end

    def mailComposeController(controller, didFinishWithResult:result)
      dismiss_modal {
        Kiln.fire_up
      }
    end

  end

  module Log
    module_function

    Error = 1
    Warning = 2
    Log = 3
    Notice = 4
    Info = 5
    Ok = 6
    Debug = 7

    Levels = {
      error: Error,
      warning: Warning,
      log: Log,
      notice: Notice,
      info: Info,
      ok: Ok,
      debug: Debug,
    }

    def level=(level)
      @level = Levels[level] || level
    end

    def level
      @level ||= Ok
    end

    def _log(type, args)
      args = [''] if args == []
      LogPlugin.add_log(type, args)
    end

    def log(*args)
      _log(:log, args)
    end

    def error(*args)
      _log(:error, args)
    end

    def ok(*args)
      _log(:ok, args)
    end

    def warning(*args)
      _log(:warning, args)
    end
    def warn(*args)
      _log(:warning, args)
    end

    def debug(*args)
      _log(:debug, args)
    end

    def notice(*args)
      _log(:notice, args)
    end

    def info(*args)
      _log(:info, args)
    end
  end

end
