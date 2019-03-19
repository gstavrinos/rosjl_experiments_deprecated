#!/usr/bin/env julia

include("../src/ROS.jl")
@ROS.rosinclude std_msgs: Empty, Int32, Float64
@ROS.rosinclude geometry_msgs: PoseStamped

function init()
    ROS.init("test_types")

    println(ROS.ok())
    k = ROS.PoseStamped2()
    println(k.pose)
    println(k.pose.position)
    println(k.pose.position.x)
    k.pose.position.x = 3
    println(k.pose.position.x)
end

init()