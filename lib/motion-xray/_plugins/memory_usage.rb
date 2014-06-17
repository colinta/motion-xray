# @requires Motion::Xray
module Motion::Xray

  class MemoryUsagePlugin < Plugin
    name 'Memory'

    def plugin_view(canvas)
      return UIView.alloc.initWithFrame(canvas.bounds).tap do |view|
        @graph = MemoryUsageGraph.initWithFrame(view.bounds.shorter(22))
        view << @graph

        button = UIButton.rounded.tap do |toggle|
          toggle.setTitle('Start', forState: :normal.uicontrolstate)
        end
        toggle.sizeToFit
        button.frame = [[8, @graph.frame.max_y + 8]]
        button.on :touch do
          toggle
        end
        view << button
      end
    end

    def toggle
      if @timer
        stop
      else
        start
      end
    end

    def start
      return if @timer

      Dispatch::Queue.main.sync do
        @timer = 0.1.every do
          tick
        end
      end
    end

    def tick
      @graph.used << FreeMem.usedMemory
      @graph.free << FreeMem.freeMemory
      @graph.setNeedsDisplay
    end

    def stop
      return unless @timer

      Dispatch::Queue.main.sync do
        @timer.invalidate
      end
    end

  end

  class MemoryUsageGraph < UIView
    attr :used
    attr :free

    def used
      @used ||= []
    end

    def free
      @free ||= []
    end

    def drawRect(rect)
      max = [free.max, used.max].max

      free_path = UIBezierPath.bezierPath
      free.each_with_index do |entry, index|
        if index == 0
          free_path.moveToPoint(index, entry)
        else
          free_path.addLineToPoint(index, entry)
        end
      end

      used_path = UIBezierPath.bezierPath
      used.each_with_index do |entry, index|
        if index == 0
          used_path.moveToPoint(index, entry)
        else
          used_path.addLineToPoint(index, entry)
        end
      end

      context = UIGraphicsGetCurrentContext()
      sx = 1
      sy = 1
      CGContextScaleCTM(context, sx, sy)
      flip_vertical = CGAffineTransformMake(
                  1, 0, 0, -1, 0, max
          );
      CGContextConcatCTM(context, flip_vertical);
    end

  end

end
