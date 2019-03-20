
abstract type ROSTYPE end

mutable struct ROSTime <: ROSTYPE
    sec::Ptr{UInt32}
    nsec::Ptr{UInt32}
end

mutable struct Header <: ROSTYPE
    seq::Ptr{UInt32}
    stamp::ROSTime
    frame_id::Ptr{String}
end

mutable struct Point <: ROSTYPE
    x::Ptr{Float64}
    y::Ptr{Float64}
    z::Ptr{Float64}
end

mutable struct Quaternion <: ROSTYPE
    x::Ptr{Float64}
    y::Ptr{Float64}
    z::Ptr{Float64}
    w::Ptr{Float64}
end

mutable struct Pose <: ROSTYPE
    position::Point
    orientation::Quaternion
end

mutable struct PoseStamped_struct <: ROSTYPE
    header::Header
    pose::Pose
end

PoseStamped_struct() = PoseStamped_struct(Header(0,ROSTime(0,0),0),Pose(Point(0,0,0),Quaternion(0,0,0,0)))

function PoseStamped_fix(cpp_type::Cxx.CxxCore.CppPtr)
    p = PoseStamped_struct()
    p.header.seq = icxx"&$cpp_type->header.seq;"
    p.header.stamp.sec = icxx"&$cpp_type->header.stamp.sec;"
    p.header.stamp.nsec = icxx"&$cpp_type->header.stamp.nsec;"
    p.header.frame_id = pointer(unsafe_string(icxx"$cpp_type->header.frame_id;"))
    p.pose.position.x = icxx"&$cpp_type->pose.position.x;"
    p.pose.position.y = icxx"&$cpp_type->pose.position.y;"
    p.pose.position.z = icxx"&$cpp_type->pose.position.z;"
    p.pose.orientation.x = icxx"&$cpp_type->pose.orientation.x;"
    p.pose.orientation.y = icxx"&$cpp_type->pose.orientation.y;"
    p.pose.orientation.z = icxx"&$cpp_type->pose.orientation.z;"
    p.pose.orientation.w = icxx"&$cpp_type->pose.orientation.w;"
    #icxx"$cpp_type->header.frame_id = \"test\";"
    #println(icxx"&p.header.frame_id;")
    return p
end

function Base.setproperty!(cpp_pointer::Quaternion, field::Symbol, value::Number)
    println("lalala1")
    if field == :x
        icxx"$(cpp_pointer.x) = $value;"
    elseif field == :y
        icxx"$(cpp_pointer.y) = $value;"
    elseif field == :z
        icxx"$(cpp_pointer.z) = $value;"
    elseif field == :w
        icxx"$(cpp_pointer.w) = $value;"
    end
end

function Base.setproperty!(cpp_pointer::Point, field::Symbol, value::Number)
    println("lalala1")
    if field == :x
        icxx"$(cpp_pointer.x) = $value;"
    elseif field == :y
        icxx"$(cpp_pointer.y) = $value;"
    elseif field == :z
        icxx"$(cpp_pointer.z) = $value;"
    end
end


function Base.setproperty!(cpp_pointer::Pose, field::Symbol, value::Quaternion)
    println("lalala1!")
    if field == :orientation
        icxx"$(cpp_pointer.orientation.x) = $(value.x);"
        icxx"$(cpp_pointer.orientation.y) = $(value.y);"
        icxx"$(cpp_pointer.orientation.z) = $(value.z);"
        icxx"$(cpp_pointer.orientation.w) = $(value.w);"
    end
end

function Base.setproperty!(cpp_pointer::Pose, field::Symbol, value::Point)
    if field == :position
        icxx"$(cpp_pointer.position.x) = $(value.x);"
        icxx"$(cpp_pointer.position.y) = $(value.y);"
        icxx"$(cpp_pointer.position.z) = $(value.z);"
    end
end

function Base.getproperty(cpp_pointer::Point, field::Symbol)
    println("lalala2")
    return unsafe_load(icxx"*$(getfield(cpp_pointer,field));")
end

function Base.getproperty(cpp_pointer::Quaternion, field::Symbol)
    println("lalala2")
    return unsafe_load(icxx"*$(getfield(cpp_pointer,field));")
end

# function Base.show(io::IO, cpp_pointer::Pose)
#     println(io,TODO)
# end

PoseStamped2() = PoseStamped_fix(@cxxnew geometry_msgs::PoseStamped())
