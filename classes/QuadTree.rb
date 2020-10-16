require "classes/Geometry.rb"

class QuadTree
  
    def initialize(boundary)
        @boundary = boundary
        @divided = false
        @point = false
    end

    def insert(point)
        if !(point.intersect_rect?(@boundary))
            return false
        end

        if !@point
            @point = point
            return true
        elsif point > @point
            smaller = @point
            @point = point
        else
            smaller = point
        end

        if !@divided
            subdivide()
        end

        @northeast.insert(smaller)
        @northwest.insert(smaller)
        @southwest.insert(smaller)
        @southeast.insert(smaller)
        return true
    end

    def subdivide()
        x = @boundary.x
        y = @boundary.y
        child_width = @boundary.w / 2
        child_height = @boundary.h / 2
 
        @northwest = QuadTree.new(Rectangle.new(x, y + child_height, child_width, child_height)) 
        @northeast = QuadTree.new(Rectangle.new(x + child_width, y + child_height, child_width, child_height)) 
        @southwest = QuadTree.new(Rectangle.new(x, y, child_width, child_height))
        @southeast = QuadTree.new(Rectangle.new(x + child_width, y, child_width, child_height))

        @divided = true
    end

    # range must be a Rectangle
    def points_in_range(range, found, args)
        
        if !range.intersect_rect?(@boundary)
            return
        end

        # add all points from this quadtree if they are in the range
        if @point && @point.intersect_rect?(range)
            found << @point
        end
        # args.state.total_checks += @points.length
        # recursive calls on each of the 4 children if children exist
        if @divided
            @northwest.points_in_range(range, found, args)
            @northeast.points_in_range(range, found, args)
            @southwest.points_in_range(range, found, args)
            @southeast.points_in_range(range, found, args)
        end
    end

    def clear
        @divided = false
        @point =false
        @northwest = nil
        @northeast = nil
        @southwest = nil
        @southeast = nil
    end

    def is_divided
        return @divided
    end

    def render args
        args.outputs.borders << @boundary.to_array()
        if @divided
            @northwest.render(args)
            @northeast.render(args)
            @southwest.render(args)
            @southeast.render(args)
        end
    end

    def debug args
        args.outputs.labels << [0, 30, self.to_s]
    end

    def serialize
        hash = {boundary: @boundary, capacity: @capacity, points: @point}
        return hash
    end

    def inspect
        serialize.to_s
    end

    def toS
        serialize.to_s
    end
    
    def to_s
        return "Quad Tree: #{serialize.to_s}"
    end
end