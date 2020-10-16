class Point
    attr_sprite
    attr_accessor :x_vel, :y_vel, :truex, :truey, :w, :h, :x, :y, :r, :g, :b, :a

    #note that x/y is the drawing position, and truex/truey are the center of the point
    def initialize(x, y, args)
        speed_values = args.state.speed_values
        @x_vel = speed_values[rand(speed_values.length)]
        @y_vel = speed_values[rand(speed_values.length)]
        @truex = x - @x_vel
        @truey = y - @y_vel
        @w = 10
        @h = 10
        @x = x - (@w / 2)
        @y = y - (@h / 2)
        @r = 255
        @g = 255
        @b = 255
        @a = 2558
        @path = 'sprites/black.png'
        args.outputs.static_sprites << self
    end

    # add each velocity component, bounce off screen border
    def move
        if @x + @x_vel < 0
            net_move = (-2 * @x) - @x_vel
            @x += net_move
            @truex += net_move
            @x_vel = -@x_vel
        elsif @x + @x_vel > (1280 - @w)
            net_move = (2 * (1280 - @w - @x)) - @x_vel 
            @x += net_move
            @truex += net_move
            @x_vel = -@x_vel
        else
            @truex += @x_vel
            @x += @x_vel
        end

        if @y + @y_vel < 0
            net_move = (-2 * @y) - @y_vel
            @y += net_move
            @truey += net_move
            @y_vel = -@y_vel
        elsif @y + @y_vel > (720 - @h)
            net_move = (2 * (720 - @h - @y)) - @y_vel 
            @y += net_move
            @truey += net_move
            @y_vel = -@y_vel
        else
            @truey += @y_vel
            @y += @y_vel
        end
    end

    def inside_rect?(rect)
        return [@truex, @truey].inside_rect?(rect)
    end

    def intersecting?(other)
        if [@x, @y, @w, @h].intersect_rect?([other.x, other.y, other.w, other.h])
            return true
        else
            return false
        end
            
    end

    def ==(other)
        other.class == self.class && other.to_hash == self.to_hash
    end

    def to_hash
        return {x: @x, y: @y, w: @w, h: @h, r: @r, g: @g, b: @b, a: @a, path: @path}
    end

    def serialize
        hash = {x: @x, y: @y}
        return hash
    end
    
    def inspect
        serialize.to_s
    end

    def toS
        serialize.to_s
    end

    def to_s
        return "Point: #{serialize.to_s}"
    end

end


class Rectangle
  
    attr_accessor :x, :y, :width, :height
    def initialize(x, y, width, height)
        @x = x 
        @y = y
        @width = width
        @height = height
    end

    def to_array
        return [@x, @y, @width, @height]
    end

    def serialize
        hash = {x: @x, y: @y, width: @width, height: @height}
        return hash
    end
    
    def inspect
        serialize.to_s
    end

    def toS
        serialize.to_s
    end

    def to_s
        return "rectangle: #{serialize.to_s}"
    end
end