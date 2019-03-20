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
    j = ROS.PoseStamped2()

    println(k.pose.orientation.x)
    j.pose.orientation.x = 1
    j.pose.orientation.z = 1
    j.pose.orientation.w = 0
    k.pose.orientation = j.pose.orientation
    k.pose.orientation.x = j.pose.orientation.w
    println(k.pose.orientation.x)
end

init()

