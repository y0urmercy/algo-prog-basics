include("../inc/robotlib.jl")

function perimetr!(robot::Robot)
    for side in [Nord,Ost,Sud,West]
        move_till_border!(robot, side, putmarker=true)
    end
end