#!/usr/bin/env julia

include("../src/ROS.jl")
@ROS.rosinclude std_msgs: Empty, Int32

ROS.init("lalala")

println(ROS.ok())


nh = ROS.NodeHandle()

msg = ROS.std_msgs_Int32

println(fieldnames(msg))

msg_ = ROS.std_msgs_Int32()

#println(msg_)
#println(msg_.data)

ROS.set(msg, :data, 3)

pub = ROS.advertise(nh, "hell_yeah", msg, 1)


while ROS.ok()
    ROS.spinOnce()
    ROS.publish(pub, 3)
end
