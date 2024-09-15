using HorizonSideRobots


function inverse_side(side::HorizonSide)
    return HorizonSide((Int(side)+2)%4)
end

function start_position!(robot::Robot)
    for side in [West,Sud]
        steps_till_border::Integer = move_till_border!(robot, side, putmarker=false)
        move_steps!(robot, inverse_side(side), steps_till_border, putmarker=false)    
    end
    return steps_till_border
end

function center_position!(robot::Robot)
    for side in [West,Sud]
        steps_till_border::Integer = move_till_border!(robot, side, putmarker=false)
        move_steps!(robot, inverse_side(side), steps_till_border//2, putmarker=false)    
    end
    return steps_till_border
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

#1
function cross!(robot::Robot)
    center_position!(robot)
    for side in [Nord,Ost,West,Sud]
        steps_till_border::Integer = move_till_border!(robot, side, putmarker=true)
        move_steps!(robot, inverse_side(side), steps_till_border, putmarker=false)
    end
    start_position!(robot)
    return true
end

#2
function perimetr!(robot::Robot)
    for side in [Nord,Ost,Sud,West]
        move_till_border!(robot, side, putmarker=true)
    end
    start_position!(robot)
    return true
end

#
function perimetr_chess!(robot::Robot)
    for side in [Nord,Ost,Sud,West]
        move_till_border_chess!(robot, side, putmarker=true)
    end
    start_position!(robot)
    return true
end

#3
function whole_place!(robot::Robot)
    side = Ost
    while !isborder(robot, Nord) || !isborder(robot, Ost) || !isborder(robot, West)
        while (!isborder(robot, side))
            putmarker!(robot)
            HorizonSideRobots.move!(robot, side)
        end
        putmarker!(robot)
        HorizonSideRobots.move!(robot, Nord)
        side = inverse_side(side)
    end
    
    putmarker!(robot)
    start_position!(robot)
    return true
end

#9
function whole_place_chess!(robot::Robot)
    side = Ost
    steps = 0
    while !isborder(robot, Nord) || !isborder(robot, Ost) || !isborder(robot, West)
        while (!isborder(robot, side))
            if (steps%2==0)
                putmarker!(robot)
            end
            HorizonSideRobots.move!(robot, side)
            steps +=1
        end
        if (steps%2==0)
            putmarker!(robot)
        end
        steps +=1
        HorizonSideRobots.move!(robot, Nord)
        side = inverse_side(side)
    end
    
    putmarker!(robot)
    start_position!(robot)
    return true
end
