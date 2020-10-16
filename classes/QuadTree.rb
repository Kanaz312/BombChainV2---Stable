require "classes/Geometry.rb"

class QuadTree
  
    def initialize(boundary, capacity)
        @boundary = boundary
        @capacity = capacity
        @divided = false
        @points = []
    end

    def insert(point)
        if (!point.inside_rect?(@boundary))
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
        capacity = @capacity
        child_size = @boundary.w / 2
 
        @northwest = QuadTree.new(Rectangle.new(x, y + child_size, child_size, child_size), capacity) 
        @northeast = QuadTree.new(Rectangle.new(x + child_size, y + child_size, child_size, child_size), capacity) 
        @southwest = QuadTree.new(Rectangle.new(x, y, child_size, child_size), capacity)
        @southeast = QuadTree.new(Rectangle.new(x + child_size, y, child_size, child_size), capacity)

        @divided = true
    end

    # range must be a Rectangle
    def points_in_range(range, found, args)
        
        if !range.intersect_rect?(@boundary)
            return
        end

        # add all points from this quadtree if they are in the range
        found.concat(@points.find_all{|point| point.inside_rect?(range)})
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