#!/usr/bin/env julia

include("../src/ROS.jl")
@ROS.rosinclude std_msgs: Empty, Int32, Float64
@ROS.rosinclude std_srvs: SetBool
@ROS.rosinclude geometry_msgs: PoseStamped

# Note to self:  CxxCore.getTypeNameAsString

function init()
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

    sub = ROS.subscribe(nh, "test_sub", 1, ROS.std_msgs_Int32, callback)
    sub2 = ROS.subscribe(nh, "test_sub2", 1, ROS.std_msgs_Float64, callback2)
    srv = ROS.advertiseService(nh, "test_srv", ROS.std_srvs_SetBool, srv_callback)
    srv2 = ROS.advertiseService(nh, "test_srv2", ROS.std_srvs_SetBool, srv_callback2)

    k = ROS.geometry_msgs_PoseStamped()
    println(k.pose.position.x)
    k.pose.position.x = 3
    println(typeof(k.pose.position.x))
    println(k.pose.position.x)
    asd

    while ROS.ok()
        ROS.spinOnce()
        ROS.publish(pub, msg)
    end
end

function srv_callback(req, res)
    println("cb")
    res.success = true
    if req.data == 1
        res.message = "We are the champions, my friend!"
    end
    return true
end

function srv_callback2(req, res)
    println("cb2")
    res.success = true
    if req.data == 1
        res.message = "We are the champions, my friend!"
    end
    return true
end

function callback(msg)
    println("sub")
    println(msg.data)
    msg.data = 100
    println(msg.data)
end

function callback2(msg)
    println("sub2")
    println(msg.data)
    msg.data = 100
    println(msg.data)
end

init()