#!/usr/bin/env julia

include("../src/ROS.jl")
@ROS.rosinclude std_msgs: Empty, Int32

ROS.init("lalala")

println(ROS.ok())


nh = ROS.NodeHandle()

msg = ROS.std_msgs_Int32()

println(typeof(msg))
println(fieldnames(typeof(msg)))
println(msg.data)
msg.data = 3
println(msg.data)

pub = ROS.advertise(nh, "hell_yeah", ROS.std_msgs_Int32, 1)


while ROS.ok()
    ROS.spinOnce()
    ROS.publish(pub, msg)
 end
