include("../inc/robotlib.jl")

function fifth_task!(robot::Robot, m::Int64, a::Int64, b::Int64) #m - кол-во клеток от внешней рамки; a, b - размеры внутреннего прямоугольника
    perimetr!(robot)
    move_steps!(robot, Ost, m)
    move_steps!(robot, Nord, m)
    rectangle!(robot, a, b)
    move_into_corner!(robot)
    move_steps!(robot, Nord, 2)
    move_steps!(robot, Ost, 2)
end