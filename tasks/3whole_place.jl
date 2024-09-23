include("../inc/robotlib.jl")

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
end