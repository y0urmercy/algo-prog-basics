using HorizonSideRobots

function go_to_border_side(robot::Robot, side)
    while !isborder(robot, side)
        move!(robot, side)
    end
end

function move_till_border!(robot::Robot, side::HorizonSide; putmarker::Bool=false)::Integer
    steps_till_border::Integer = 0

    while (!isborder(robot, side))
        (putmarker == true) && (putmarker!(robot))
        HorizonSideRobots.move!(robot, side)
        steps_till_border += 1
    end

    (putmarker == true) && (putmarker!(robot))

    return steps_till_border
end

function move_till_border_chess!(robot::Robot, side::HorizonSide; putmarker::Bool=false)::Integer
    steps_till_border::Integer = 0

    while (!isborder(robot, side))
        if (steps_till_border%2==1)
            (putmarker == true) && (putmarker!(robot))
        else
            putmarker == false
        end
        HorizonSideRobots.move!(robot, side)
        steps_till_border += 1
    end

    (putmarker == true) && (putmarker!(robot))

    return steps_till_border
end


function move_steps!(robot::Robot, side::HorizonSide, steps::Integer; putmarker::Bool=false)::Bool
    while (steps > 0)
        if (!isborder(robot, side))
            (putmarker == true) && (putmarker!(robot))
            HorizonSideRobots.move!(robot, side)
            steps -= 1
        else
            return false
        end
    end

    (putmarker == true) && (putmarker!(robot))

    return true
end

function move_steps_chess!(robot::Robot, side::HorizonSide, steps::Integer; putmarker::Bool=false)::Bool
    while (steps > 0)
        if (!isborder(robot, side))
            if (steps%2!=1)
                (putmarker == true) && (putmarker!(robot))
            else
                putmarker == false
            end
            HorizonSideRobots.move!(robot, side)
            steps -= 1
        else
            return false
        end
    end

    (putmarker == true) && (putmarker!(robot))

    return true
end

function rectangle!(robot::Robot, a::Int64, b::Int64)
    putmarker!(robot)
    move_steps!(robot, Nord, a, putmarker=true)
    move_steps!(robot, Ost, b, putmarker=true)
    move_steps!(robot, Sud, a, putmarker=true)
    move_steps!(robot, West, b, putmarker=true)
end

function center_position!(robot::Robot)
    for side in [Ost,Nord]
        steps_till_border::Integer = trunc(Int, move_till_border!(robot, side, putmarker=false)/2)
        move_steps!(robot, inverse_side(side), steps_till_border, putmarker=false)    
    end
    return true
end

##

function reverse_side(side::HorizonSide)::HorizonSide
    return HorizonSide((Int(side)+2)%4)
end


function next_side(side::HorizonSide)::HorizonSide
    return HorizonSide((Int(side)+1)%4)
end


function reverse_path(path::Vector{HorizonSide})::Vector{HorizonSide}
    reversed_sides::Vector{HorizonSide} = []
    foreach(side -> push!(reversed_sides, reverse_side(side)), path)

    return reverse!(reversed_sides)
end


function reverse_path(path::Vector{Tuple{HorizonSide, T}})::Vector{Tuple{HorizonSide, T}} where T <: Integer
    return reverse!(map(p -> (reverse_side(p[1]), p[2]), path))
end


# move to direction side untill stop_cond
function HorizonSideRobots.move!(stop_cond::Function, robot::Robot, side::HorizonSide)::Integer
    steps_untill_stop_cond::Integer = 0

    while (!stop_cond(robot, side))
        HorizonSideRobots.move!(robot, side)
        steps_untill_stop_cond += 1
    end

    return steps_untill_stop_cond
end


function move_with_act!(stop_cond::Function,
                        robot::Robot, side::HorizonSide;
                        pre_act::Function, post_act::Function)::Vector{HorizonSide}
    traversed_path::Vector{HorizonSide} = []

    while (!stop_cond(robot, side))
        pre_act(robot)
        HorizonSideRobots.move!(robot, side)
        push!(traversed_path, side)
        post_act(robot)
    end

    return traversed_path
end


function iscorner(robot::Robot)::Bool
    for side_v in [Nord, Sud]
        for side_h in [West, Sud]
            (isborder(robot, side_v) && isborder(robot, side_h)) && (return true)
        end
    end

    return false
end


function which_border(robot::Robot)::Tuple{Bool, HorizonSide}
    for side in [Nord, Sud, West, Ost]
        (isborder(robot, side)) && (return (true, side))
    end

    return (false, Nord)
end


function which_borders(robot::Robot)::Tuple{Bool, Vector{HorizonSide}}
    border_sides::Vector{HorizonSide} = []
    for side in [Nord, Sud, West, Ost]
        (isborder(robot, side)) && (push!(border_sides, side))
    end

    return (!isempty(border_sides), border_sides)
end


function move_into_corner!(robot::Robot; side_v::HorizonSide=Sud, side_h::HorizonSide=West)::Tuple{Bool, Vector{Tuple{HorizonSide, Integer}}}
    traversed_path::Vector{Tuple{HorizonSide, Integer}} = []

    # TODO infinite loop in a trap
    #
    # |  R  |  <-- trap
    # + --- +
    while (!isborder(robot, side_v) || !isborder(robot, side_h))
        for side in [side_v, side_h]
            steps = move!(isborder, robot, side)
            push!(traversed_path, (side, steps))
        end
    end

    # NOTE do not change return type now to save function interface
    return (true, traversed_path)
end


function mark_direction!(robot::Robot, side::HorizonSide)::Integer
    steps_in_direction::Integer = 0

    putmarker!(robot)
    while (!isborder(robot, side))
        move!(robot, side)
        steps_in_direction += 1
        putmarker!(robot)
    end

    return steps_in_direction
end


function mark_direction!(robot::Robot, side::HorizonSide, steps::T)::Tuple{Bool, T} where T <: Integer
    traversed_steps::T = 0

    putmarker!(robot)
    while (traversed_steps < steps)
        (isborder(robot, side)) && (return (false, traversed_steps))

        move!(robot, side)
        traversed_steps += 1
        putmarker!(robot)
    end

    return (true, steps)
end


function mark_direction!(robot::Robot, side_v::HorizonSide, side_h::HorizonSide)::Vector{Tuple{HorizonSide, Integer}}
    traversed_path::Vector{Tuple{HorizonSide, Integer}} = []

    putmarker!(robot)
    while (!isborder(robot, side_v) && !isborder(robot, side_h))
        move!(robot, side_v)
        push!(traversed_path, (side_v, 1))

        move!(robot, side_h)
        push!(traversed_path, (side_h, 1))

        putmarker!(robot)
    end

    return traversed_path
end

