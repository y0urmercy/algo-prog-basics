using HorizonSideRobots as HSR

#Перемещение на n клеток в заданном направлении
HSR.move!(robot, side, n_steps) =
 for _ in 1:n_steps move!(robot, side) end

#Перемещает робота, если это возможно
function trymove!(robot, side)
    isborder(robot, side) && return false
    move!(robot, side)
    return true
end

#Перемещает робота в угол
function movetoangle!(robot, side::NTuple{2,HorizonSide})
    path = HorizonSide[]
    while !(isborder(robot, side[1]) && isborder(robot, side[2]))
    # робот - не в углу
        trymove!(robot, side[1]) && push!(path, side[1])
        trymove!(robot, side[2]) && push!(path, side[2])
    end
    return path
end

#Перемещает робота до границы
function movetoend!(robot, side)
    while trymove!(robot, side) 
    end
end

#Абстрактный тип робота
abstract type AbstractRobot end
move!(robot::AbstractRobot, side) = HSR.move!(getbaserobot(robot), side)
isborder(robot::AbstractRobot, side) = HSR.isborder(getbaserobot(robot), side)
putmarker!(robot::AbstractRobot) = HSR.putmarker!(getbaserobot(robot))
ismarker(robot::AbstractRobot) = HSR.ismarker(getbaserobot(robot))
temperature(robot::AbstractRobot) = HSR.temperature(getbaserobot(robot))

#BorderRobot для обхода простых перегородок
struct BorderRobot <: AbstractRobot
    robot::Robot
end

getbaserobot(robot::Robot) = robot
getbaserobot(robot::BorderRobot) = robot.robot

struct MarkRobot{TypeRobot} <: AbstractRobot
    robot::TypeRobot
end

getbaserobot(robot::MarkRobot) = getbaserobot(robot.robot)

struct XBorderRobot <: AbstractRobot
    robot::Robot
end

getbaserobot(robot::XBorderRobot) = robot.robot

HSR.move!(robot::XBorderRobot, side::HorizonSide) = move!(robot.robot, side)
HSR.isborder(robot::XBorderRobot, side) = isborder(robot.robot, side[1])

function trymove!(robot::BorderRobot, side)::Bool
    nsteps = nummovetoend!(robot, right(side)) do
        !isborder(robot, side) || isborder(robot, right(side))
    end
    if !isborder(robot, side)
        move!(robot, side)
        if nsteps > 0 
            movetoend!(robot, side) do 
                !isborder(robot, left(side))
            end
        end 
        result = true
    else
        result = false
    end
    move!(robot, left(side), nsteps)
    return result 
end

function markdirect!(robot::BorderRobot, side)
    while !isborder(robot, side)
        trymove!(robot, side)
        putmarker!(robot)
    end
end

#Переопределение функций
movetoend!(stop_condition::Function, robot, side) = for !stop_condition() move!(robot, side) end
nummovetoend!(stop_condition::Function, robot, side) = begin
    n = 0
    for !stop_condition() move!(robot, side)
        n += 1
    end
end
HSR.move!(robot::Any, side::Any) = for s in side move!(robot, s) end
left(side::HorizonSide) = HorizonSide(mod(Int(side)+1, 4))
right(side::HorizonSide) = HorizonSide(mod(Int(side)+3, 4))
inverse(side::HorizonSide) = HorizonSide(mod(Int(side)+2, 4))
left(side) = left.(side)
right(side) = right.(side)
inverse(side) = inverse.(side)
'4. ДАНО: Робот находится в произвольной клетке ограниченного
прямоугольного поля без внутренних перегородок и маркеров.
РЕЗУЛЬТАТ: Робот — в исходном положении в центре косого креста из
маркеров, расставленных вплоть до внешней рамки.'
#Расставляет маркеры в заданном направлении
function markdirect!(robot, side)
    while !isborder(robot, side)
        move!(robot, side)
        putmarker!(robot)
    end
end
#Переопределение функций для передачи аргумента в виде Tuple из двух значений HorizonSide.
HSR.isborder(robot, side::Any) = isbborder(robot, side[1]) || isborder(robot, side[2])
HSR.move!(robot, side::Any) = for s in side move!(robot, s) end

#Расставляет маркеры до границы (в заданных направлениях)
function markcross!(robot, sides = (Nord, Ost, Sud, West))
    for s = sides
        n = markdirect!(robot, s)
        move!(robot, inverse(s), n)
    end
end

#Вызов функции косого креста
markcross!(r, ((Nord, Ost), (Sud, Ost), (Sud, West), (Nord, West)))

'5. ДАНО: На ограниченном внешней прямоугольной рамкой поле имеется
ровно одна внутренняя перегородка в форме прямоугольника. Робот - в
произвольной клетке поля между внешней и внутренней перегородками.
РЕЗУЛЬТАТ: Робот - в исходном положении и по всему периметру
внутренней, как внутренней, так и внешней, перегородки поставлены маркеры.'

#Расставляет маркеры по периметру
function markperim!(robot)
    for s in (Nord, Ost, Sud, West)
        putmarker!(robot)
        markdirect!(robot, s) 
    end
end


'6. ДАНО: Робот - в произвольной клетке ограниченного прямоугольного
поля, на котором могут находиться также внутренние прямоугольные
перегородки (все перегородки изолированы друг от друга, прямоугольники
могут вырождаться в отрезки)
РЕЗУЛЬТАТ: Робот - в исходном положении и
a) по всему периметру внешней рамки стоят маркеры;
б) маркеры не во всех клетках периметра, а только в 4-х позициях -
напротив исходного положения робота.'

#Перемещение робота по периметру
function markperim!(robot::BorderRobot)
    for s in (Nord, Ost, Sud, West)
        putmarker!(robot)
        markdirect!(robot, s) 
    end
end

function marker_start_sides(robot::BorderRobot)
    for s in (Nord, Ost, Sud, West)
        movetoend!(robot, s)
        putmarker!(robot)
        movetoend!(robot, reverse(s))
    end
end

'7. ДАНО: Робот - рядом с горизонтальной бесконечно продолжающейся в
обе стороны перегородкой (под ней), в которой имеется проход шириной в одну
клетку.
РЕЗУЛЬТАТ: Робот - в клетке под проходом'

function find_door()
    putmarker!(robot)
    flag_door::Bool = false
    (!isborder(robot, Nord)) && (flag_door = true)

    steps_in_direction::Int = 1
    side::HorizonSide = next_side(Nord)
    while (!flag_door)
        move!(robot, side, steps_in_direction)
        (!isborder(robot, Nord)) && (flag_door = true)
        steps_in_direction += 1
        side = reverse_side(side)
    end

    move!(robot, Nord)
end

'8. ДАНО: Где-то на неограниченном со всех сторон поле без внутренних
перегородок имеется единственный маркер. Робот - в произвольной клетке этого
поля.
РЕЗУЛЬТАТ: Робот - в клетке с маркером.'

function findmarker!(robot)::nothing
    max_nsteps = 0
    side = Nord
    while !findmarker!(robot, side, max_nsteps)
        side = left(side)
        (side in (nord, Sud)) && (max_nsteps += 1)
    end
end

function findmarker!(robot, side, max_nsteps)::Bool
    for _ in 0:max_nsteps
        ismarker(robot) && return true
        move!(robot, side)
    end
    return ismarker(robot)
end

'9. ДАНО: Робот - в произвольной клетке ограниченного прямоугольного
поля (без внутренних перегородок)
РЕЗУЛЬТАТ: Робот - в исходном положении, на всем поле расставлены
маркеры в шахматном порядке, причем так, чтобы в клетке с роботом находился
маркер'

mutable struct ChessRobot
    robot::Robot
    flag::Bool
end

function HSR.move!(robot::ChessRobot, side)
    move!(robot.robot, side)
    flag && putmarker!(robot.robot)
    robot.flag = !robot.flag
end

function HSR.move!(robot::ChessRobot{N}, side) where N <:
    Integer
    x = robot.coord.x % 2N
    y = robot.coord.y % 2N
    if ((x in 0:N-1) && (y in 0:N-1)) || ((x in N:2N-1) && (x in N:2N-1))
        putmarker!(robot.robot)
    end
    move!(robot.robot, side)
end

chesmark!(robot::Robot, N::Int) = snake!(ChessRobot{N}(robot, Coordinates(0,0)), (Ost, Nord)) do side
    isborder(robot, side) && isborder(robot, Nord)
 end

HSR.isborder(robot::ChessRobot, side) = isborder(robot.robot, side)
markperim!(robot::Robot) = perimetr!(ChessRobot(r, true))


'10. ДАНО: Робот - в произвольной клетке ограниченного прямоугольного
поля (без внутренних перегородок)
РЕЗУЛЬТАТ: Робот - в исходном положении, и на всем поле расставлены
маркеры в шахматном порядке клетками размера N*N (N-параметр функции),
начиная с юго-западного угла'

function rectarea!(robot)
    side = Ost
    movetoend!(robot, side)
    while !isborder(robot, Nord)
        move!(robot, Nord)
        side = inverse(side)
        movetoend!(robot, side)
    end
end

function chesmark!(robot::Robot, N::Int)
    coord = (x = Ref(0), y = Ref(0))
    robot = (;robot, coord, N)
    rectarea!(robot)
end

function HSR.move!(
    robot::@NamedTuple{x::Base.RefValue{Int64}, y::Base.RefValue{Int64}},
    side
    )
    x = robot.coord.x[] % 2N
    y = robot.coord.y[] % 2N
    (((x in 0:N-1) && (y in 0:N-1)) || ((x in N:2N-1) && (x in N:2N-1))
    ) && putmarker!(robot.robot)
    move!(robot.robot, side)
end


'11. ДАНО: Робот - в произвольной клетке ограниченного прямоугольного
поля, на поле расставлены горизонтальные перегородки различной длины
(перегородки длиной в несколько клеток, считаются одной перегородкой), не
касающиеся внешней рамки.
РЕЗУЛЬТАТ: Робот — в исходном положении, подсчитано и возвращено
число всех перегородок на поле.'

function numborders!(robot, side)
    state = 1
    num_borders = 1
    while !isborder(robot, side)
        move!(robot, side)
        if state == 0
            (isborder(robot, Nord) == true) && (state = 1; num_borders += 1)
        elseif state == 1
            (isborder(robot, Nord) == false) && (state = 0)
        end
    end
    return num_borders
end

'12. Отличается от предыдущей задачи тем, что если в перегородке имеются
разрывы не более одной клетки каждый, то такая перегородка считается одной
перегородкой.'

mutable struct CountBorders
    robot::Robot
    num_borders::Int
    state::Int
end

function HSR.move!(robot::CountBorders, side)
    move!(robot.robot, side)
    if state == 0 
        (isborder(robot, Nord) == true) && (state = 1; num_borders +=1)
    elseif state == 1
        (isborder(robot.robot, Nord) == false) && (state = 2)
    elseif state == 2 
        (isborder(robot, Nord) == false) && (state = 0)
    end
end
HSR.isborder(robot::CountBorder, side) = isborder(robot.robot, side)

function numborders2!(r::Robot, side)
    r = CountRobot(r, 1, 1)
    movetoend!(r, side)
    return r.num_borders
end

'13. Решить задачу 9 с использованием обобщённой функции
snake!(robot,
(move_side, next_row_side)::NTuple{2,HorizonSide} =
(Ost,Nord))'

mutable struct Coordinates
    x::Int
    y::Int
end
coord = Coordinates(0, 0)

function HSR.move!(coord::Coordinates, side::HorizonSide)
    if side == Nord
        coord.y += 1
    elseif side == Sud
        coord.y -= 1
    elseif side == Ost
        coord.x += 1
    else #if side == West
        coord.x -= 1
    end
    nothing
end

mutable struct ChessRobot{N}
    robot::Robot
    coord::Coordinates
end

HorizonSideRobot.isborder(robot::ChessRobot, side) = isborder(robot.robot, side)

function HSR.move!(robot::ChessRobot{N}, side) where N <:
    Integer
    x = robot.coord.x % 2N
    y = robot.coord.y % 2N
    if ((x in 0:N-1) && (y in 0:N-1)) || ((x in N:2N-1) && (x in N:2N-1))
        putmarker!(robot.robot)
    end
    move!(robot.robot, side)
end

function snake!(stop_condition::Function, robot, sides::NTuple{2, HorizonSide})
    s = side[1]
    while !stop_condition()
        movetoend!(()->stop_condition || isborder(robot, s), robot, s)
        if stop_condition()
            break
        end
        s = inverse(s)
        move!(robot, sides[2])
    end
end
chesmark!(robot::Robot, N::Int) = snake!(ChessRobot{N}(robot, Coordinates(0,0)), (Ost, Nord)) do side
    isborder(robot, side) && isborder(robot, Nord) end

'14. Решить предыдущую задачу, но при условии наличия на поле простых
внутренних перегородок.
Под простыми перегородками мы понимаем изолированные
прямолинейные или прямоугольные перегородки.'

function snake!(stop_condition::Function, robot::Robot, TypeRobot::DataType, sides::NTuple{2, HorizonSide})
    robot = MarkRobot{TypeRobot}(TypeRobot(robot))
    s = side[1]
    while !stop_condition()
        movetoend!(()->stop_condition || isborder(robot, s), robot, s)
        if stop_condition()
            break
        end
        s = inverse(s)
        move!(robot, sides[2])
    end
end
chesmark!(robot::BorderRobot, N::Int) = snake!(ChessRobot{N}(robot, Coordinates(0,0)), (Ost, Nord)) do side
    isborder(robot, side) && isborder(robot, Nord) end

'15. Решить задачу 4, но при условии наличия на поле простых внутренних
перегородок.'

#Расставляет маркеры в заданном направлении
function markdirect!(robot::Robot, TypeRobot::DataType, side)
    robot = MarkRobot{TypeRobot}(TypeRobot(robot))
    while !isborder(robot, side)
        trymove!(robot, side)
        putmarker!(robot)
    end
end

#Расставляет маркеры до границы (в заданных направлениях)
function markcross!(robot::Robot, TypeRobot::DataType, sides = (Nord, Ost, Sud, West))
    robot = MarkRobot{TypeRobot}(TypeRobot(robot))
    for s = sides
        n = markdirect!(robot, s)
        trymove!(robot, inverse(s), n)
    end
end

#Вызов функции косого креста
Robot(robot::XBorderRobot) = robot 
markcross!(robot, ((Nord, Ost), (Sud, Ost), (Sud, West), (Nord, West)))


'16. Решить задачу 7 с использованием обобщённой функции
shuttle!(stop_condition::Function, robot, side)'

function shuttle!(stop_condition::Function, robot, start_side)
    s = start_side
    n = 0
    while !stop_condition(s)
        move!(robot, s, n)
        s = inverse(s)
        n += 1
    end
end

movetodoor!(r::Robot) = shuttle!(_->isborder(r, Nord), r, West) 

'17. Решить задачу 8 с использованием обобщённой функции
spiral!(stop_condition::Function, robot)'

function spiral!(stop_condition::Function, robot)
    nmax_steps = 1
    s = Nord
    while !find_direct!(stop_condition, robot, s, nmax_steps)
        (s in (Nord, Sud)) && nmax_steps += 1
        s = left(s)
    end
end

function find_direct!(stop_condition, robot, side, nmax_steps)
    n = 0
    while stop_condition(s) == false || n < nmax_steps
        move!(robot, side)
        n += 1
    end
    return  stop_condition(x)
end

movetomarker!(r::Robot) = spiral!(_->ismarker(r), r) 

'18. Решить предыдущую задачу, но при дополнительном условии:
а) на поле имеются внутренние изолированные прямолинейные
перегородки конечной длины (только прямолинейных, прямоугольных
перегородок нет);
б) некоторые из прямолинейных перегородок могут быть
полубесконечными.'

movetomarker!(r::BorderRobot) = spiral!(_->ismarker(r), r) 

'19. Написать рекурсивную функцию, перемещающую робота до упора в
заданном направлении.'

function movetoend_recursion!(robot, side)
    (!isborder(robot, side)) && movetoend_recursion(robot, side)
end

'20. Написать рекурсивную функцию, перемещающую робота до упора в
заданном направлении, ставящую возле перегородки маркер и возвращающую
робота в исходное положение.'

function movetoend_recursion!(robot, side, putmarker=false, n_steps=0)
    (!isborder(robot, side)) && (n_steps += 1;movetoend_recursion(robot, side, n_steps))
    if putmarker == true
        putmarker!(robot)
        move!(robot, reverse(side), n_steps=n_steps)
end
