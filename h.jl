using HorizonSideRobots

# TODO import HorizonSideRobots as HSR
using HorizonSideRobots


function inverse_side(side::HorizonSide)
    return HorizonSide((Int(side)+2)%4)
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


# TODO [overload] ... move!(..., steps::Integer=1; ...)::Bool
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


function cross!(robot::Robot)
    for side in [Nord,Ost,West,Sud]
        steps_till_border::Integer = move_till_border!(robot, side, putmarker=true)
        move_steps!(robot, inverse_side(side), steps_till_border, putmarker=false)
    end
end

