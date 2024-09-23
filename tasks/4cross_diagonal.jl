include("../inc/robotlib.jl")

function cross_diagonal!(robot::Robot)
    start_position!(robot)
    putmarker!(robot)
    while !isborder(robot, Nord) && !isborder(robot, Ost)
        move!(robot, Nord)
        move!(robot, Ost)
        putmarker!(robot)
    end
    go_to_border_side(robot, West)
    putmarker!(robot)
    while !isborder(robot, Sud) && !isborder(robot, Ost)
        move!(robot, Sud)
        move!(robot, Ost)
        putmarker!(robot)
    end
end