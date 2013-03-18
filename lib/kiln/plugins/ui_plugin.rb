module Kiln

  class UIPlugin < Plugin
    name 'UI'

    def initialize
      @editor_instances = []
    end

    def kiln_view_in(canvas)
      @editors = Kiln::TypewriterView.alloc.initWithFrame(canvas.bounds)
      @editors.scroll_view = canvas
      @editors
    end

    def kiln_edit(target)
      super
      @editors.subviews.each &:removeFromSuperview
      @editor_instances = []

      properties = @target.kiln
      sections = properties.keys
      properties.each do |section, editors|
        section_view = SectionHeader.alloc.initWithFrame([[0, 0], [Kiln.ui.full_screen_width, 20]])
        section_view.text = section
        @editors << section_view
        editors.each do |property, editor_class|
          next unless editor_class

          editor_instance = editor_class.with_target(@target, property:property)
          @editor_instances << editor_instance
          section_view.tracking_view << editor_instance.get_edit_view(@editors.bounds)
        end
        @editors << section_view.tracking_view
      end
      @editors.layoutIfNeeded
    end

  end

end
