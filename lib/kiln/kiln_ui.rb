module Kiln
  module_function

  def ui
    @kiln ||= UI.new
  end

  def toggle
    Kiln.ui.toggle
  end

  def fire_up
    Kiln.ui.fire_up
  end

  def cool_down
    Kiln.ui.cool_down
  end

end

module Kiln
  class UI
    attr :assign_button
    attr :back_button
    attr :top_bar
    attr :bottom_bar
    attr :canvas
    attr :label
    attr :revert
    attr :selected
    attr :editing
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

    def window
      UIApplication.sharedApplication.keyWindow || UIApplication.sharedApplication.windows[0]
    end

    def app_shared
      UIApplication.sharedApplication
    end

    def app_bounds
      UIScreen.mainScreen.bounds
    end

    def full_screen_width
      window.bounds.width
    end

    def full_screen_height
      window.bounds.height
    end

    def half_screen_width
      full_screen_width / 2
    end

    def half_screen_height
      if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone
        window.bounds.height / 2
      else
        512
      end
    end

    def bottom_half_height
      full_screen_height - half_screen_height
    end

    def bar_height
      30
    end

    def label_top
      half_screen_height
    end

    def label_height
      25
    end

    def canvas_top
      label_top + label_height
    end

    def canvas_height
      bottom_half_height - label_height
    end

    def fired?
      @fired
    end

    def build_the_ui(teh_transform)
      unless @teh_ui
        @teh_ui = UIView.alloc.initWithFrame(window.bounds)

        @cover = UIView.alloc.initWithFrame(@teh_ui.bounds)
        @cover.layer.transform = teh_transform
        @teh_ui << @cover

        @selector = UIView.alloc.init
        @selector.layer.borderWidth = 1
        @selector.layer.borderColor = '#a91105'.uicolor.cgcolor
        @selector.layer.opacity = 0
        @teh_ui << @selector

        @top_bar = HeaderBackground.alloc.initWithFrame([[full_screen_width, 0], [half_screen_width, bar_height]])
        @top_bar.label = HeaderLabel.alloc.initWithFrame(@top_bar.bounds.right(30).thinner(30))

        @back_button = UIButton.detail
        @back_button.transform = CGAffineTransformMakeRotation(180.degrees)
        @back_button.enabled = false
        @back_button.on :touch {
          back
        }
        @top_bar << @back_button
        @teh_ui << @top_bar

        @bottom_bar = HeaderBackground.alloc.initWithFrame([[full_screen_width, half_screen_height - bar_height], [half_screen_width, bar_height]])
        @bottom_bar.label = HeaderLabel.alloc.initWithFrame(@bottom_bar.bounds.right(3).thinner(33))
        @teh_ui << @bottom_bar

        @assign_button = UIButton.detail
        @assign_button.transform = CGAffineTransformMakeRotation(90.degrees)
        @assign_button.frame = @assign_button.frame.x(half_screen_width - @assign_button.frame.width)
        @assign_button.on :touch {
          edit(@selected) if @selected
        }
        @bottom_bar << @assign_button

        @table = UITableView.alloc.initWithFrame(CGRect.empty, style: :plain.uitableviewstyle)
        @table.frame = [[full_screen_width, bar_height], [half_screen_width, half_screen_height - bar_height * 2]]
        @table.rowHeight = 20
        @table.delegate = self
        @teh_ui << @table

        @label = HeaderBackground.alloc.initWithFrame([[0, label_top + bottom_half_height], [full_screen_width, label_height]])
        @label.label = HeaderLabel.alloc.initWithFrame(@label.bounds)
        @label.label.font = 'Futura'.uifont(9)
        @teh_ui << @label

        @canvas = UIScrollView.alloc.init
        @canvas.frame = [[0, canvas_top + bottom_half_height], [full_screen_width, canvas_height]]
        grad_layer = CAGradientLayer.layer
        grad_layer.frame = @canvas.layer.bounds
        grad_layer.colors = [:white.uicolor.cgcolor, :lightgray.uicolor.cgcolor]
        @canvas.layer << grad_layer
        @editors = Kiln::TypewriterView.alloc.initWithFrame(@canvas.bounds)
        @canvas << @editors
        @teh_ui << @canvas
      end

      @selector.fade_in
      @top_bar.frame = @top_bar.frame.x(full_screen_width)
      @top_bar.slide :left, half_screen_width
      @bottom_bar.frame = @bottom_bar.frame.x(full_screen_width)
      @bottom_bar.slide :left, half_screen_width
      @table.frame = @table.frame.x(full_screen_width)
      @table.slide :left, half_screen_width

      @label.frame = @label.frame.y(label_top + bottom_half_height)
      @label.slide :up, bottom_half_height
      @canvas.frame = @canvas.frame.y(canvas_top + bottom_half_height)
      @canvas.slide :up, bottom_half_height

      window << @teh_ui
    end

    def fire_up
      return if @fired
      @fired = true

      # gather all window subviews into 'revert_view'
      @revert = {
        views: [],
        status_bar_was_hidden?: app_shared.statusBarHidden?,
        transforms: {}
      }

      dx = -app_bounds.width / 4
      dy = -app_bounds.height / 4

      teh_transform = CATransform3DScale(CATransform3DMakeTranslation(dx, dy, 0), 0.5, 0.5, 1)
      window.subviews.each do |subview|
        @revert[:views] << subview
        @revert[:transforms][subview] = subview.layer.transform

        UIView.animate {
          subview.layer.transform = teh_transform
        }
      end
      app_shared.setStatusBarHidden(true, withAnimation:UIStatusBarAnimationSlide)

      build_the_ui(teh_transform)

      if @selected && ! @selected.isDescendantOfView(window)
        @selected = nil
      end
      if @editing && ! @editing.isDescendantOfView(window)
        @editing = nil
      end
      select(window, update:true) unless @selected
      edit(window) unless @editing
      app_shared.setStatusBarHidden(true, withAnimation:UIStatusBarAnimationSlide)
    end

    def cool_down
      return unless @fired
      @fired = false

      @selector.fade_out
      @top_bar.slide(:right, half_screen_width)
      @bottom_bar.slide(:right, half_screen_width)
      @table.slide(:right, half_screen_width)
      @label.slide(:down, bottom_half_height)
      @canvas.slide(:down, bottom_half_height) {
        @teh_ui.removeFromSuperview
      }

      @revert[:views].each do |subview|
        UIView.animate {
          # identity matrix
          subview.layer.transform = @revert[:transforms][subview]
          subview.layer.anchorPoint = [0.5, 0.5]
        }
      end
      app_shared.setStatusBarHidden(@revert[:status_bar_was_hidden?], withAnimation:UIStatusBarAnimationSlide)
      @revert = nil
    end

    def select(selected, update:update_table)
      return unless selected

      @selected = selected
      SugarCube::Adjust::adjust(@selected)

      @bottom_bar.text = @selected.class.name

      if update_table
        if @selected == window
          subviews = @revert[:views]
        else
          subviews = @selected.subviews
        end
        @top_bar.text = @selected.class.name
        @table_source = Kiln::TableSource.new(@selected.superview, subviews)
        @table.dataSource = @table_source
        @table.delegate = self
        @table.reloadSections([0].nsindexset, withRowAnimation: :fade.uitablerowanimation)

        @back_button.enabled = !!@selected.superview
      end

      UIView.animate {
        if @selected == window
          selector_frame = [[0, 0], [half_screen_width, half_screen_height]]
        else
          selector_frame = window.convertRect(@selected.bounds, fromView:@selected)
        end
        @selector.frame = selector_frame
      }
    end

    def edit(editing)
      @editing = editing
      @label.text = @editing.inspect
      properties = @editing.kiln
      sections = properties.keys
      properties.each do |section, editors|
        section_view = Kiln::SectionHeader.alloc.initWithFrame([[0, 0], [full_screen_width, 20]])
        section_view.text = section
        @editors << section_view
        editors.each do |property,editor|
          section_view.tracking_view << editor.with_property(property).get_edit_view(@editing, @editors.bounds)
        end
        @editors << section_view.tracking_view
      end
    end

    def back
      select(@table_source.superview, update:true)
    end

    def tableView(table_view, didSelectRowAtIndexPath:index_path)
      table_selection = @table_source.subviews[index_path.row]
      if @selected == table_selection
        table_view.deselectRowAtIndexPath(index_path, animated:true)
        select(table_selection.superview, update:false)
      else
        select(table_selection, update:false)
      end
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
        cell = Kiln::TableCell.alloc.initWithStyle(:default.uitablecellstyle,
                            reuseIdentifier: cell_identifier)
        cell.kiln = table_view.delegate
      end

      cell.textLabel.text = @subviews[index_path.row].to_s
      cell.row = index_path.row
      cell.detail_button.off :touch
      if @subviews[cell.row].subviews.length > 0
        cell.detail_button.show
        cell.detail_button.on :touch {
          cell.kiln.select(@subviews[cell.row], update:true)
        }
      else
        cell.detail_button.hide
      end

      return cell
    end

  end


  class TableCell < UITableViewCell
    attr_accessor :kiln
    attr_accessor :row
    attr :detail_button

    def initWithStyle(style, reuseIdentifier:identifier)
      super.tap do
        textLabel.font = UIFont.systemFontOfSize(10)
        textLabel.lineBreakMode = :clip.uilinebreakmode
        @detail_button = UIButton.detail_disclosure
        @detail_button.frame = [[143.0, -0.5], [17.0, 19.0]]
        contentView << @detail_button
      end
    end

    def touchesBegan(touches, withEvent:event)
      super
      NSLog("=============== kiln.rb line #{__LINE__} ===============")
    end

    def touchesMoved(touches, withEvent:event)
      super
      NSLog("=============== kiln.rb line #{__LINE__} ===============")
    end

    def touchesEnded(touches, withEvent:event)
      super
      NSLog("=============== kiln.rb line #{__LINE__} ===============")
    end

    def touchesCancelled(touches, withEvent:event)
      super
      NSLog("=============== kiln.rb line #{__LINE__} ===============")
    end

  end
end
