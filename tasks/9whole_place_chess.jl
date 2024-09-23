include("../inc/robotlib.jl")

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
    move_into_corner!(robot)
end