require "classes/Geometry.rb"

class QuadTree
  
    def initialize(boundary, capacity)
        @boundary = boundary
        @capacity = capacity
        @divided = false
        @points = []
    end

    def insert(point)
        if (!point.inside_rect?(@boundary.to_array))
            return false
        end
        if @points.length() < @capacity
            @points.append(point)
            return true
        else
            if !@divided
                subdivide()
            end

            if @northeast.insert(point) || @northwest.insert(point) || @southwest.insert(point) || @southeast.insert(point)
                return true
            end
        end
    end

    def subdivide()
        x = @boundary.x
        y = @boundary.y
        half_width = @boundary.width / 2
        half_height = @boundary.height / 2
 
        nw = Rectangle.new(x, y + half_height, half_width, half_height)
        @northwest = QuadTree.new(nw, @capacity) 
        ne = Rectangle.new(x + half_width, y + half_height, half_width, half_height)
        @northeast = QuadTree.new(ne, @capacity)
        sw = Rectangle.new(x, y, half_width, half_height) 
        @southwest = QuadTree.new(sw, @capacity)
        se = Rectangle.new(x + half_width, y, half_width, half_height)
        @southeast = QuadTree.new(se, @capacity)

        @divided = true
    end

    # range must be a Rectangle
    def points_in_range(range, found)
        if !@boundary.to_array.intersect_rect?(range.to_array)
            return
        end

        # add all points from this quadtree if they are in the range
        @points.each do |point|
            if point.inside_rect?(range.to_array)
                found << point
            end
        end

        # recursive calls on each of the 4 children if children exist
        if @divided
            @northwest.points_in_range(range, found)
            @northeast.points_in_range(range, found)
            @southwest.points_in_range(range, found)
            @southeast.points_in_range(range, found)
        end
    end

    def clear
        @divided = false
        @points = []
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
        hash = {boundary: @boundary, capacity: @capacity, points: @points.length()}
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