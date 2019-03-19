
abstract type ROSTYPE end

mutable struct ROSTime <: ROSTYPE
    sec::UInt32
    nsec::UInt32
end

mutable struct Header <: ROSTYPE
    seq::UInt32
    stamp::ROSTime
    frame_id::String
end

mutable struct Point <: ROSTYPE
    x::Float64
    y::Float64
    z::Float64
end

mutable struct Quaternion <: ROSTYPE
    x::Float64
    y::Float64
    z::Float64
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

PoseStamped_struct() = PoseStamped_struct(Header(0,ROSTime(0,0),""),Pose(Point(0,0,0),Quaternion(0,0,0,0)))

function PoseStamped_fix(cpp_type::Cxx.CxxCore.CppPtr)
    t = cpp_type
    p = PoseStamped_struct()
    p.header.seq = icxx" $cpp_type->header.seq;"
    p.header.stamp.sec = icxx" $cpp_type->header.stamp.sec;"
    p.header.stamp.nsec = icxx" $cpp_type->header.stamp.nsec;"
    p.pose.position.x = icxx" $cpp_type->pose.position.x;"
    p.pose.position.y = icxx" $cpp_type->pose.position.y;"
    p.pose.position.z = icxx" $cpp_type->pose.position.z;"
    p.pose.orientation.x = icxx" $cpp_type->pose.orientation.x;"
    p.pose.orientation.y = icxx" $cpp_type->pose.orientation.y;"
    p.pose.orientation.z = icxx" $cpp_type->pose.orientation.z;"
    p.pose.orientation.w = icxx" &$cpp_type->pose.orientation.w;"
    p.pose.orientation.w = 5
    println(p.pose.orientation.w)
    println(icxx" $cpp_type->pose.orientation.w;")
    return p
end

function Base.setproperty!(cpp_pointer::Quaternion, field::Symbol, value)
    println("lalala1")
    if field == :w
        icxx"*$(cpp_pointer.w) = $value;"
    end
end

function Base.getproperty(cpp_pointer::Cxx.CxxCore.CppPtr, field::Symbol)
    println("lalala2")
    return cxx"cpp_pointer->$field;"
end

PoseStamped2() = PoseStamped_fix(@cxxnew geometry_msgs::PoseStamped())
