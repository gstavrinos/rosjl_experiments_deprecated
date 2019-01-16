#!/usr/bin/env julia

ENV["JULIA_CXX_RTTI"]=1
using Cxx
using Libdl

function init()
    ros_header_dir = "/opt/ros/melodic/include"
    ros_lib_dir = "/opt/ros/melodic/lib"
    addHeaderDir(ros_header_dir, kind = C_System)
    cxxinclude(joinpath(ros_header_dir,"ros/ros.h"))
    Libdl.dlopen(joinpath(ros_lib_dir, "libroscpp.so"), Libdl.RTLD_GLOBAL)
    # addHeaderDir(joinpath(ros_header_dir, "ros"), kind = C_System)
    # addHeaderDir(joinpath(ros_header_dir, "xmlrpcpp"), kind = C_System)
    # addHeaderDir(joinpath(ros_header_dir, "roscpp"), kind = C_System)
    # cxxinclude(joinpath(ros_header_dir,"xmlrpcpp/XmlRpc.h"))
    #prepend!(ARGS,PROGRAM_FILE)
    println(pushfirst!(ARGS,PROGRAM_FILE))
    println(pointer([pointer("imu_node")]))
    println(pointer(pointer.(ARGS)))
    cxx"""
    #include <iostream>
    int argc;
    char **argv;
    //ros::NodeHandle nh;
    """
end

# function ros_init(node_name::String)
#     println(PROGRAM_FILE)
#     println(ARGS)
#     cxx"""
#     ros::init($:(length(ARGS), ARGS, node_name));
#     """
# end

ros_spin() = @cxx ros::spin()
ros_ok() = @cxx ros::ok()
ros_init(node_name::String) = @cxx ros::init(Int32(length(ARGS)+1), pointer(pointer.(pushfirst!(ARGS,PROGRAM_FILE))), pointer(node_name))
#@cxx ros::init(Int32(1), pointer([pointer("imu_node")]), pointer("imu_node"))
NodeHandle() = @cxxnew ros::NodeHandle()

init()

ros_init("lalala")

println(ros_ok())

nh = NodeHandle()

println(nh->get_param("asdasd","dddd"))


while ros_ok()
    @cxx ros::spinOnce()
end
#ros_ok()
