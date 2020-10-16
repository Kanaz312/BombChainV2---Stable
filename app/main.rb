require "classes/Geometry.rb"
require "classes/QuadTree.rb"

def tick args
    args.state.tick_start ||= Time.now
    args.state.tick_time = Time.now - args.state.tick_start
    args.state.tick_start = Time.now
    args.state.clear! if args.inputs.keyboard.key_down.r # Reset when you press r
    init(args) unless args.state.populated
    
    mouse_actions(args.inputs.mouse, args)
    tree = args.state.tree
    tree.clear
    update_points(args.state.points, tree, args)
    if args.state.range
        check_user_range(args)
    end

    render args
    debug(args)
    args.state.end_time = Time.now
end

def init args
    args.state.capacity ||= 1
    boundary ||= Rectangle.new(0, 0, 1280, 720)
    quad_tree ||= QuadTree.new(boundary, args.state.capacity)
    args.state.tree ||= quad_tree
    args.state.drawing ||= false
    args.state.points ||= []
    args.state.range ||= false
    args.state.points_inside ||= []
    args.state.original_x ||= 0
    args.state.original_y ||= 0
    args.state.speed_values ||= []
    args.state.end_time ||= 0
    args.state.populated = true
    2.times do |i|
        if i != 0
            args.state.speed_values << i
            args.state.speed_values << -i
        end
    end
    200.times do |i|
        point = Point.new(10 + rand(1260), 10 + rand(700), args)
        quad_tree.insert(point)
        args.state.points << point
    end
end

def update_points(points, tree, args)
    args.state.total_collision_time = 0
    total_insertion_time = 0
    loop_start_time = Time.now
    possible_points = []
    # for each point, generate a check range three points (sprites) wide centered on the point
    # use the quadtree to find all points in that range
    # for each of those points check collision using intersect_rect? (intersecting basically just calls intersect_rect?)
    # if colliding, make both sprites red
    points.each do |point|
        point.path = "sprites/black.png"
        point.move
        possible_points.clear()
        start_time = Time.now
        tree.points_in_range(point.collider, point.collider.to_array, possible_points)
        args.state.total_collision_time += Time.now - start_time
        possible_points.each do |other|
            if point.intersecting?(other)
                point.path = "sprites/red.png"
            end
        end
        insertion_time = Time.now
        tree.insert(point)
        total_insertion_time += Time.now - insertion_time
    end
    args.state.collision_time = Time.now - loop_start_time
    args.state.avg_loop_time = (Time.now - loop_start_time) / points.length
    args.state.avg_insertion_time = total_insertion_time
    args.state.avg_collision_time = args.state.total_collision_time
end

def mouse_actions(mouse, args)
    # left mouse gereates a new sprite
    # right mouse starts drawing a box, pressing again stop drawing
    #   the box is used as a range for checking points later
    if mouse.down
        if mouse.button_left
            point = Point.new(mouse.x, mouse.y, args)
            args.state.tree.insert(point)
            args.state.points << point
        end

        if args.state.range
            if mouse.button_right
                args.state.range = false
                args.state.points_inside.each do |point|
                    point.path = "sprites/black.png"
                end
            end
        else
            if mouse.button_right
                args.state.range = Rectangle.new(mouse.x, mouse.y, 0, 0)
                args.state.original_x = mouse.x
                args.state.original_y = mouse.y
            end
        end
    end
end

def check_user_range(args)
    # get the list of points from last frame
    old_points = args.state.points_inside + []
    
    # update the range based on the user's mouse
    range = args.state.range
    change_range_corner(args, range, args.inputs.mouse)

    # generate the new list of points
    # revert all the old points back to black if not in the new list
    new_points = []
    args.state.tree.points_in_range(range, range.to_array, new_points)
    points_to_revert = old_points - new_points
    points_to_revert.each do |point|
        point.path = "sprites/black.png"
    end

    # for each point in the new list, make it green
    new_points.each do |point|
        point.path = "sprites/green.png"
    end
    args.state.points_inside = new_points
end

def change_range_corner(args, range, mouse)
    original_x = args.state.original_x
    original_y = args.state.original_y
    range.w = (original_x - mouse.x).abs()
    range.h = (original_y - mouse.y).abs()
    x = original_x
    y = original_y

    if original_x > mouse.x
        x = mouse.x
    end
    if original_y > mouse.y
        y = mouse.y
    end

    range.x = x
    range.y = y
end

def render(args)
    if args.state.range.respond_to?('to_array')
        args.outputs.borders << args.state.range.to_array()
    end
end

def debug(args)
    
    args.outputs.labels << [0, 140, "Tick_time: #{args.state.tick_time}"]
    args.outputs.labels << [0, 120, "FPS: #{args.gtk.current_framerate.to_s.to_i}"]
    args.outputs.labels << [0, 100, "avg loop time: #{args.state.avg_loop_time}"]
    args.outputs.labels << [0, 80, "avg insertion time: #{args.state.avg_insertion_time}"]
    args.outputs.labels << [0, 60, "avg collision time: #{args.state.avg_collision_time}"]
    args.outputs.labels << [0, 40, "sprite reset time: #{args.state.sprite_reset_time}"]
    args.outputs.labels << [0, 20, "collision time: #{args.state.collision_time}"]
end




#-----------------------------------------------------------------------------------------------------
# deprecated
# def collisions(points, tree, args)
#     args.state.total_collision_time = 0
#     loop_start_time = Time.now
#     possible_points = []
#     # for each point, generate a check range three points (sprites) wide centered on the point
#     # use the quadtree to find all points in that range
#     # for each of those points check collision using intersect_rect? (intersecting basically just calls intersect_rect?)
#     # if colliding, make both sprites red
#     points.each do |point|
#         point.path = "sprites/black.png"
#         point.move
#         possible_points.clear()
#         start_time = Time.now
#         tree.points_in_range(point.collider, point.collider.to_array, possible_points)
#         args.state.total_collision_time += Time.now - start_time
#         possible_points.each do |other|
#             if point.intersecting?(other)
#                 point.path = "sprites/red.png"
#             end
#         end
#         tree.insert(point)
#     end
#     args.state.collision_time = Time.now - loop_start_time
#     args.state.avg_loop_time = (Time.now - loop_start_time) / points.length
#     args.state.avg_collision_time = args.state.total_collision_time
# end