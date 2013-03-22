module Kiln

  class KilnViewController < UIViewController

    def loadView
      self.view = Kiln.ui.teh_ui
    end

    def supportedInterfaceOrientations
      UIInterfaceOrientationPortrait
    end

    def shouldAutorotate
      false
    end

    def willAnimateRotationToInterfaceOrientation(orientation, duration:duration)
      Kiln.ui.update_orientation
    end

  end

  class UI
    attr :teh_ui
    attr :assign_button
    attr :top_bar
    attr :bottom_bar
    attr :bottom_half
    attr :canvas
    attr :label
    attr :revert
    attr :selected
    attr :target
    attr :cover
    attr :selector
    attr :subviews
    attr :superview
    attr :table
    attr :table_source

    def toggle
      if fired?
        cool_down
      else
        fire_up
      end
      return fired?
    end

    def full_screen_width
      Kiln.window.bounds.width
    end

    def full_screen_height
      Kiln.window.bounds.height
    end

    def half_screen_width
      full_screen_width / 2
    end

    def half_screen_height
      Kiln.window.bounds.height / 2
    end

    def bottom_half_height
      full_screen_height - half_screen_height
    end

    def bar_height
      30
    end

    def bottom_half_top
      half_screen_height
    end

    def toolbar_top
      bottom_half_height - 25
    end

    def toolbar_height
      25
    end

    def canvas_top
      0
    end

    def canvas_height
      bottom_half_height - toolbar_height
    end

    def fired?
      @fired
    end

    def build_the_ui
      unless @teh_ui
        @teh_ui = UIView.alloc.initWithFrame(Kiln.window.bounds)
        @kiln_controller = KilnViewController.new

        @tiny_view = UIView.alloc.initWithFrame([[0, 0], [half_screen_width, half_screen_height]])
        @teh_ui << @tiny_view

        @cover = UIControl.alloc.initWithFrame([[0, 0], [half_screen_width, half_screen_height]])
        @cover.on :touch {
          Kiln.cool_down
          2.seconds.later do
            Kiln.fire_up
          end
        }
        @teh_ui << @cover

        @selector = UIView.alloc.init
        @selector.userInteractionEnabled = false
        @selector.layer.borderWidth = 1
        @selector.layer.borderColor = '#a91105'.uicolor.cgcolor
        @selector.layer.opacity = 0
        @teh_ui << @selector

        @top_half = UIView.alloc.initWithFrame([[half_screen_width, 0], [half_screen_width, half_screen_height]])
        @teh_ui << @top_half

        @table = UITableView.alloc.initWithFrame(CGRect.empty, style: :plain.uitableviewstyle)
        @table.frame = [[0, bar_height], [half_screen_width, half_screen_height - bar_height * 2]]
        @table.rowHeight = 30
        @table.delegate = self
        @table.autoresizingMask = :full.uiautoresizemask
        @top_half << @table

        @top_bar = KilnHeaderBackground.alloc.initWithFrame([[0, 0], [half_screen_width, bar_height]])
        @top_bar.autoresizingMask = :fixed_top.uiautoresizemask
        @top_bar.label = KilnHeaderLabel.alloc.initWithFrame(@top_bar.bounds.right(30).thinner(30))
        @top_bar.label.autoresizingMask = :flexible_width.uiautoresizemask

        @expand_button = KilnDetailButton.alloc.init
        @expand_button.transform = CGAffineTransformMakeRotation(180.degrees)
        @expand_button.on :touch {
          toggle_picker
        }
        @top_bar << @expand_button

        @choose_button = UIButton.custom
        @choose_button.setImage('kiln_choose_button'.uiimage, forState: :normal.uicontrolstate)
        @choose_button.sizeToFit
        f = @choose_button.frame
        f.origin = @top_bar.bounds.top_right + CGPoint.new(-4 - f.width, 4)
        @choose_button.frame = f
        @choose_button.on :touch {
          choose_view
        }
        @choose_button.autoresizingMask = :fixed_top_right.uiautoresizemask
        @top_bar << @choose_button

        @top_half << @top_bar

        @bottom_bar = KilnHeaderBackground.alloc.initWithFrame([[0, half_screen_height - bar_height], [half_screen_width, bar_height]])
        @bottom_bar.label = KilnHeaderLabel.alloc.initWithFrame(@bottom_bar.bounds.right(3).thinner(33))
        @bottom_bar.label.autoresizingMask = :flexible_width.uiautoresizemask
        @bottom_bar.autoresizingMask = :fixed_bottom.uiautoresizemask
        @top_half << @bottom_bar

        @assign_button = KilnDetailButton.alloc.init
        @assign_button.transform = CGAffineTransformMakeRotation(90.degrees)
        @assign_button.frame = @assign_button.frame.x(half_screen_width - @assign_button.frame.width)
        @assign_button.on :touch {
          edit(@selected) if @selected
        }
        @assign_button.autoresizingMask = :fixed_bottom_right.uiautoresizemask
        @bottom_bar << @assign_button

        @bottom_half = UIView.alloc.initWithFrame([[0, bottom_half_top], [full_screen_width, bottom_half_height]])
        grad_layer = CAGradientLayer.layer
        grad_layer.frame = @bottom_half.layer.bounds
        grad_layer.colors = [:white.uicolor.cgcolor, :lightgray.uicolor.cgcolor]
        @bottom_half.layer << grad_layer
        @teh_ui << @bottom_half

        @canvas = KilnScrollView.alloc.init
        @canvas.frame = [[0, canvas_top], [full_screen_width, canvas_height]]
        @bottom_half << @canvas

        @toolbar = PluginToolbar.alloc.initWithFrame([[-1, toolbar_top], [full_screen_width + 2, toolbar_height + 1]])
        @toolbar.canvas = @canvas
        @bottom_half << @toolbar

        Kiln.plugins.each do |plugin|
          @toolbar.add(plugin)
        end
      end

      @tiny_view.subviews.each &:removeFromSuperview
    end

    def transition_ui
      @selector.fade_in

      @top_half.frame = @top_half.frame.x(full_screen_width)
      @top_half.slide :left, half_screen_width

      @bottom_half.frame = @bottom_half.frame.y(full_screen_height)
      @bottom_half.slide :up, bottom_half_height
    end

    def fire_up
      return if @fired
      @fired = true
      Kiln.window.first_responder && Kiln.window.first_responder.resignFirstResponder

      # gather all window subviews into 'revert_view'
      @revert = {
        views: [],
        status_bar_was_hidden?: Kiln.app_shared.statusBarHidden?,
        transforms: {}
      }

      Kiln.window.subviews.each do |subview|
        @revert[:views] << subview
        @revert[:transforms][subview] = subview.layer.transform
      end
      Kiln.app_shared.setStatusBarHidden(true, withAnimation:UIStatusBarAnimationSlide)

      build_the_ui
      @old_controller = Kiln.window.rootViewController
      Kiln.window.rootViewController = @kiln_controller
      @revert[:views].each do |view|
        @tiny_view << view
      end

      transition_ui
      apply_transform(true)

      if @selected && ! @selected.isDescendantOfView(Kiln.window)
        @selected = nil
      end
      if @target && ! @target.isDescendantOfView(Kiln.window)
        @target = nil
      end

      subviews = view_tree
      @table_source = KilnTableSource.new(@selected || Kiln.window, subviews)
      @table.dataSource = @table_source
      @table.delegate = self

      select(Kiln.window) unless @selected
      edit(Kiln.window) unless @target
    end

    def cool_down
      return unless @fired
      @fired = false

      @selector.fade_out
      @top_half.slide(:right, half_screen_width)
      @bottom_half.slide(:down, bottom_half_height) {
        Kiln.window.rootViewController = @old_controller
        @old_controller = nil

        @teh_ui.removeFromSuperview
      }

      @revert[:views].each do |subview|
        Kiln.window << subview
        UIView.animate {
          # identity matrix
          subview.layer.transform = @revert[:transforms][subview]
          subview.layer.anchorPoint = [0.5, 0.5]
        }
      end
      Kiln.app_shared.setStatusBarHidden(@revert[:status_bar_was_hidden?], withAnimation:UIStatusBarAnimationSlide)
      @revert = nil
    end

    def view_tree(view=nil, indent=nil, depth=0, is_last=true, return_views=[])
      if view
        subviews = view.kiln_subviews
      else
        view = Kiln.window
        subviews = @revert[:views]
      end

      if indent
        next_indent = indent.dup
        if is_last
          indent += '`-- '
          next_indent += '    '
        else
          indent += '+-- '
          next_indent += '|   '
        end
      else
        indent = ''
        next_indent = ''
      end

      return_views << {view: view, indent: indent}.to_object

      subviews.each_with_index { |subview, index|
        view_tree(subview, next_indent, depth + 1, index == subviews.length - 1, return_views)
      }
      return return_views
    end

    def choose_view
      restore_shown_views = collect_views

      @choose_view = UIView.alloc.initWithFrame(Kiln.window.bounds)
      @choose_view.backgroundColor = :black.uicolor
      @choose_view.opaque = true
      @choose_view.alpha = 0.0

      controls = @revert[:views].reverse.map { |subview|
        buttony_views(subview)
      }.flatten

      restore_shown_views.each do |subview|
        subview.show
      end

      label = UILabel.alloc.initWithFrame([[5, 5], [0, 0]])
      label.backgroundColor = :clear.uicolor
      label.textColor = :white.uicolor
      label.textAlignment = :left.uitextalignment

      container = UIView.alloc.initWithFrame(CGRect.empty)
      container.layer.cornerRadius = label.frame.height/2
      container.backgroundColor = :black.uicolor(0.5)
      container << label

      controls.reverse.each do |control|
        control.container = container
        control.label = label
        @choose_view << control
      end

      @choose_view << container

      Kiln.window << @choose_view
      @choose_view.fade_in
      timer = 0
    end

    def did_choose_view(view)
      radius = Math.sqrt(Kiln.window.bounds.width**2 + Kiln.window.bounds.height**2)
      window_center = Kiln.window.center
      @choose_view.subviews.each do |subview|
        angle = window_center.angle_to(subview.center)
        random_x = radius * Math.cos(angle)
        random_y = radius * Math.sin(angle)
        subview.move_to([random_x, random_y], 1)
      end
      0.5.later do
        @choose_view.fade_out_and_remove
      end
      edit(view)
      select(view)
    end

    def collect_views(view=nil)
      if view
        # join all the subviews
        view.kiln_subviews.reverse.map { |subview|
          collect_views(subview)
        }.flatten + [view]
      else
        # start at the revert[:views] and collect all subviews
        @revert[:views].reverse.map { |subview|
          collect_views(subview)
        }.flatten.select { |subview| !subview.hidden? }
      end
    end

    def buttony_views(view)
      children = view.kiln_subviews.reverse.map { |subview|
        buttony_views(subview)
      }.flatten

      f = view.convertRect(view.bounds, toView:nil)
      f.origin.x *= 2
      f.origin.y *= 2
      f.size.width *= 2
      f.size.height *= 2

      btn = KilnChooseViewButton.alloc.initWithFrame(view.bounds)
      btn.transform = view.transform
      btn.frame = f
      btn.target = view
      btn.on(:touch_down_repeat) {
        did_choose_view(view)
      }

      btn.children = children

      btn.setImage(view.uiimage, forState: :normal.uicontrolstate)
      btn.layer.borderColor = :white.uicolor.cgcolor
      btn.layer.borderWidth = 1
      children.each do |subbtn|
        btn << subbtn
      end
      view.hide

      children + [btn]
    end

    def select(selected)
      return unless selected

      @selected = selected
      @top_bar.text = @selected.class.name

      UIView.animate {
        if @selected == Kiln.window
          selector_frame = [[0, 0], [half_screen_width, half_screen_height]]
        else
          selector_frame = Kiln.window.convertRect(@selected.bounds, fromView:@selected)
        end
        @selector.frame = selector_frame
      }
    end

    def edit(target)
      collapse_picker
      @bottom_bar.text = target.to_s

      Kiln.plugins.each do |plugin|
        plugin.kiln_edit(target)
      end
      @target = target
      SugarCube::Adjust::adjust(target)
      reset
    end

    def reset
      @toolbar.show
      @canvas.contentOffset = [0, 0]
    end

    def toggle_picker
      if @picker_is_expanded
        collapse_picker
      else
        expand_picker
      end
    end

    def expand_picker
      return if @picker_is_expanded
      UIView.animate {
        @top_half.frame = [[0, 0], [full_screen_width, half_screen_height]]
        @expand_button.transform = CGAffineTransformMakeRotation(0.degrees)
      }
      @picker_is_expanded = true
    end

    def collapse_picker
      return unless @picker_is_expanded
      UIView.animate {
        @top_half.frame = [[half_screen_width, 0], [half_screen_width, half_screen_height]]
        @expand_button.transform = CGAffineTransformMakeRotation(180.degrees)
      }
      @picker_is_expanded = false
    end

    def tableView(table_view, didSelectRowAtIndexPath:index_path)
      table_selection = @table_source.subviews[index_path.row].view
      if @selected == table_selection
        edit(table_selection)
      else
        select(table_selection)
      end
    end

    def update_orientation(animate=true)
      case UIApplication.sharedApplication.statusBarOrientation
      when UIInterfaceOrientationPortrait
      when UIInterfaceOrientationPortraitUpsideDown
      when UIInterfaceOrientationLandscapeLeft
      when UIInterfaceOrientationLandscapeRight
      end

      apply_transform
      select(@selected)
      edit(@target)
    end

    def apply_transform(animate=true)
      dx = -Kiln.app_bounds.width / 4
      dy = -Kiln.app_bounds.height / 4
      teh_transform = CATransform3DMakeTranslation(dx, dy, 0)
      teh_transform = CATransform3DScale(teh_transform, 0.5, 0.5, 1)

      case UIApplication.sharedApplication.statusBarOrientation
      when UIInterfaceOrientationPortraitUpsideDown
        teh_transform = CATransform3DRotate(teh_transform, 180.degrees, 0, 0, 1)
      when UIInterfaceOrientationLandscapeLeft
        teh_transform = CATransform3DRotate(teh_transform, -90.degrees, 0, 0, 1)
      when UIInterfaceOrientationLandscapeRight
        teh_transform = CATransform3DRotate(teh_transform, 90.degrees, 0, 0, 1)
      end
      UIView.animate(duration: animate ? nil : 0) do
        @revert[:views].each do |subview|
          subview.layer.transform = teh_transform
        end
      end
    end

    def get_screenshot
      scale = UIScreen.mainScreen.scale
      UIGraphicsBeginImageContextWithOptions(Kiln.window.bounds.size, false, scale)
      context = UIGraphicsGetCurrentContext()

      @revert[:views].each do |subview|
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, subview.frame.origin.x, subview.frame.origin.y)
        subview.layer.renderInContext(context)
        CGContextRestoreGState(context)
      end
      image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return image
    end

  end


  class KilnTableSource
    attr :selected
    attr :subviews

    def initialize(selected, subviews)
      @selected = selected
      @subviews = subviews
    end

    def [](index)
      @subviews[index]
    end

    ##|
    ##|  TABLEVIEW
    ##|
    def numberOfSectionsInTableView(table_view)
      1
    end

    def tableView(table_view, numberOfRowsInSection:section)
      @subviews.length
    end

    def tableView(table_view, cellForRowAtIndexPath:index_path)
      cell_identifier = "KilnTableCell"
      cell = table_view.dequeueReusableCellWithIdentifier(cell_identifier)

      unless cell
        cell = KilnTableCell.alloc.initWithStyle(:default.uitablecellstyle,
                            reuseIdentifier: cell_identifier)
      end

      view_info = @subviews[index_path.row]
      view = view_info.view
      cell.view = view
      text = ''
      indent = view_info.indent
      text << indent << view.to_s
      cell.textLabel.text = text
      cell.row = index_path.row
      cell.detail_button.off :touch
      cell.detail_button.hide

      return cell
    end

  end


  class KilnTableCell < UITableViewCell
    attr_accessor :view
    attr_accessor :row
    attr :detail_button

    def initWithStyle(style, reuseIdentifier:identifier)
      super.tap do
        textLabel.font = UIFont.systemFontOfSize(10)
        textLabel.lineBreakMode = :clip.uilinebreakmode
        @detail_button = KilnDetailButton.alloc.init
        @detail_button.frame = [[143, -0.5], [17, 19]]
        contentView << @detail_button

        self.detail_button.on :touch {
          Kiln.ui.select(self.view) if self.view
        }

      end
    end

  end

  class KilnDetailButton < UIButton

    def init
      initWithFrame([[0, 0], [27, 29]])
    end

    def initWithFrame(frame)
      super.tap do
        setImage('kiln_detail_button'.uiimage, forState: :normal.uicontrolstate)
      end
    end

    def pointInside(point, withEvent:event)
      bounds.contains?(point)
    end

  end

  class KilnChooseViewButton < UIButton
    attr_accessor :container
    attr_accessor :label
    attr_accessor :target
    attr_accessor :children

    def initWithFrame(frame)
      super.tap do
        self.backgroundColor = :clear.uicolor
        @@fade_out_timer = nil
        @@slide_out_timer = nil

        self.on(:touch_down) {
          start_touch
        }
        self.on(:touch_stop) {
          stop_touch
        }
      end
    end

    def slide_out_timer=(timer)
      if @@slide_out_timer
        @@slide_out_timer.invalidate
      end
      @@slide_out_timer = timer
    end

    def fade_out_timer=(timer)
      if @@fade_out_timer
        @@fade_out_timer.invalidate
      end
      @@fade_out_timer = timer
    end

    def start_touch
      if @@fade_out_timer
        self.fade_out_timer = nil
        @container.alpha = 1
      else
        @container.alpha = 0
        @container.fade_in
      end

      @label.text = target.inspect
      @label.sizeToFit
      @label.frame = @label.frame.width([Kiln.window.frame.width - 10, @label.frame.width].min)
      @container.frame = @label.bounds.grow(5)
      @container.center = @container.superview.center

      self.backgroundColor = :black.uicolor(0.5)
      self.slide_out_timer = 1.second.later do
        stop_touch
        slide_out
        @@slide_out_timer = nil
      end
    end

    def stop_touch
      self.backgroundColor = :clear.uicolor
      self.slide_out_timer = nil
      self.fade_out_timer = 1.second.later do
        @container.fade_out
        @@fade_out_timer = nil
      end
    end

    def slide_out
      self.children.each do |child|
        child.slide_out
      end
      self.slide(:up, Kiln.window.bounds.width) {
        self.removeFromSuperview
      }
    end

  end

end
