include("../inc/robotlib.jl")

function perimetr_chess!(robot::Robot)
    for side in [Nord,Ost,Sud,West]
        move_till_border_chess!(robot, side, putmarker=true)
    end
    move_into_corner!(robot)
    return true
end