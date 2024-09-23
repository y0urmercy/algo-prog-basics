include("../inc/robotlib.jl")


function cross!(robot::Robot)
    center_position!(robot)
    for side in [Nord,Ost]
        go_to_border_side(robot, side)
        move_till_border!(robot, reverse_side(side), putmarker=true)
        center_position!(robot)
    end
    move_into_corner!(robot)
    return true
end