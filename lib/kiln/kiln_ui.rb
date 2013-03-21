module Kiln
  class UI
    attr :assign_button
    attr :back_button
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

        @cover = UIControl.alloc.initWithFrame(@teh_ui.bounds)
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

        @top_half = UIView.alloc.initWithFrame([[0, 0], [half_screen_width, half_screen_height]])
        @teh_ui << @top_half

        @table = UITableView.alloc.initWithFrame(CGRect.empty, style: :plain.uitableviewstyle)
        @table.frame = [[0, bar_height], [half_screen_width, half_screen_height - bar_height * 2]]
        @table.rowHeight = 20
        @table.delegate = self
        @top_half << @table

        @top_bar = KilnHeaderBackground.alloc.initWithFrame([[0, 0], [half_screen_width, bar_height]])
        @top_bar.label = KilnHeaderLabel.alloc.initWithFrame(@top_bar.bounds.right(30).thinner(30))

        @back_button = KilnDetailButton.alloc.init
        @back_button.transform = CGAffineTransformMakeRotation(180.degrees)
        @back_button.enabled = false
        @back_button.on :touch {
          back
        }
        @top_bar << @back_button

        @choose_button = UIButton.custom
        @choose_button.setImage('kiln_choose_button'.uiimage, forState: :normal.uicontrolstate)
        @choose_button.sizeToFit
        f = @choose_button.frame
        f.origin = @top_bar.bounds.top_right + CGPoint.new(-4 - f.width, 4)
        @choose_button.frame = f
        @choose_button.on :touch {
          choose_view
        }
        @top_bar << @choose_button

        @top_half << @top_bar

        @bottom_bar = KilnHeaderBackground.alloc.initWithFrame([[0, half_screen_height - bar_height], [half_screen_width, bar_height]])
        @bottom_bar.label = KilnHeaderLabel.alloc.initWithFrame(@bottom_bar.bounds.right(3).thinner(33))
        @top_half << @bottom_bar

        @assign_button = KilnDetailButton.alloc.init
        @assign_button.transform = CGAffineTransformMakeRotation(90.degrees)
        @assign_button.frame = @assign_button.frame.x(half_screen_width - @assign_button.frame.width)
        @assign_button.on :touch {
          edit(@selected) if @selected
        }
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

      @selector.fade_in

      @top_half.frame = @top_half.frame.x(full_screen_width)
      @top_half.slide :left, half_screen_width

      @bottom_half.frame = @bottom_half.frame.y(full_screen_height)
      @bottom_half.slide :up, bottom_half_height

      Kiln.window << @teh_ui
    end

    def fire_up
      return if @fired
      @fired = true
      Kiln.window.first_responder && Kiln.window.first_responder.resignFirstResponder

      UIDeviceOrientationDidChangeNotification.add_observer(self, :'orientation_changed:')

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
      apply_transform(true)

      if @selected && ! @selected.isDescendantOfView(Kiln.window)
        @selected = nil
      end

      select(Kiln.window) unless @selected
      if @target && ! @target.isDescendantOfView(Kiln.window)
        @target = nil
      end
      edit(Kiln.window) unless @target
      reset
    end

    def cool_down
      return unless @fired
      @fired = false

      UIDeviceOrientationDidChangeNotification.remove_observer(self)

      @selector.fade_out
      @top_half.slide(:right, half_screen_width)
      @bottom_half.slide(:down, bottom_half_height) {
        @teh_ui.removeFromSuperview
      }

      @revert[:views].each do |subview|
        UIView.animate {
          # identity matrix
          subview.layer.transform = @revert[:transforms][subview]
          subview.layer.anchorPoint = [0.5, 0.5]
        }
      end
      Kiln.app_shared.setStatusBarHidden(@revert[:status_bar_was_hidden?], withAnimation:UIStatusBarAnimationSlide)
      @revert = nil
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

      label = UILabel.alloc.initWithFrame(@choose_view.bounds)
      label.backgroundColor = :clear.uicolor
      label.textColor = :white.uicolor
      label.textAlignment = :center.uitextalignment

      controls.reverse.each do |control|
        control.label = label
        @choose_view << control
      end

      @choose_view << label

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
      select(view.superview || view)
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
      # f = f.left(Kiln.window.bounds.width)

      btn = KilnChooseViewButton.alloc.initWithFrame(f)
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
      select(selected, update:true)
    end
    def select(selected, update:update_table)
      return unless selected

      @selected = selected
      SugarCube::Adjust::adjust(@selected)

      if update_table
        if @selected == Kiln.window
          subviews = @revert[:views]
        else
          subviews = @selected.kiln_subviews
        end
        @top_bar.text = @selected.class.name
        @table_source = Kiln::TableSource.new(@selected.superview, subviews)
        @table.dataSource = @table_source
        @table.delegate = self
        @table.reloadSections([0].nsindexset, withRowAnimation: :fade.uitablerowanimation)

        @back_button.enabled = !!@selected.superview
      end

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
      @bottom_bar.text = target.to_s

      Kiln.plugins.each do |plugin|
        plugin.kiln_edit(target)
      end
      @target = target
      reset
    end

    def reset
      @toolbar.show
      @canvas.contentOffset = [0, 0]
    end

    def back
      select(@table_source.superview)
    end

    def tableView(table_view, didSelectRowAtIndexPath:index_path)
      table_selection = @table_source.subviews[index_path.row]
      if @selected == table_selection
        table_view.deselectRowAtIndexPath(index_path, animated:true)
        if table_selection.subviews.length > 0
          select(table_selection)
        else
          edit(table_selection)
        end
      else
        select(table_selection, update:false)
      end
    end

    def orientation_changed(notification)
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
      @cover.layer.transform = teh_transform
      UIView.animate(duration: animate ? nil : 0) do
        @revert[:views].each do |subview|
          subview.layer.transform = teh_transform
        end
      end
    end

    def get_screenshot
      scale = UIScreen.mainScreen.scale
      UIGraphicsBeginImageContextWithOptions(App.window.bounds.size, false, scale)
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


  class TableSource
    attr :superview
    attr :subviews

    def initialize(superview, subviews)
      @superview = superview
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
        cell.kiln = table_view.delegate
      end

      cell.textLabel.text = @subviews[index_path.row].to_s
      cell.row = index_path.row
      cell.detail_button.off :touch
      if @subviews[cell.row].subviews.length > 0
        cell.detail_button.show
        cell.detail_button.on :touch {
          cell.kiln.select(@subviews[cell.row])
        }
      else
        cell.detail_button.hide
      end

      return cell
    end

  end


  class KilnTableCell < UITableViewCell
    attr_accessor :kiln
    attr_accessor :row
    attr :detail_button

    def initWithStyle(style, reuseIdentifier:identifier)
      super.tap do
        textLabel.font = UIFont.systemFontOfSize(10)
        textLabel.lineBreakMode = :clip.uilinebreakmode
        @detail_button = KilnDetailButton.alloc.init
        @detail_button.frame = [[143, -0.5], [17, 19]]
        contentView << @detail_button
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
    attr_accessor :label
    attr_accessor :target
    attr_accessor :children

    def initWithFrame(frame)
      super.tap do
        self.backgroundColor = :clear.uicolor
        @timer = nil

        self.on(:touch_down) {
          start_touch
        }
        self.on(:touch_stop) {
          stop_touch
        }
      end
    end

    def start_touch
      @label.text = target.inspect
      @label.alpha = 0
      @label.fade_in

      self.backgroundColor = :black.uicolor(0.5)
      @timer = 1.second.later do
        stop_touch
        slide_out
      end
    end

    def stop_touch
      self.backgroundColor = :clear.uicolor
      @timer.invalidate if @timer
      @timer = nil
      1.later do
        @label.fade_out
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
