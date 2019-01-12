#!/usr/bin/env julia

ENV["JULIA_CXX_RTTI"]=1
using Cxx

function init()
    ros_header_dir = "/opt/ros/melodic/include"
    addHeaderDir(ros_header_dir, kind = C_System)
    addHeaderDir(joinpath(ros_header_dir, "ros"), kind = C_System)
    addHeaderDir(joinpath(ros_header_dir, "xmlrpcpp"), kind = C_System)
    addHeaderDir(joinpath(ros_header_dir, "roscpp"), kind = C_System)
    cxxinclude(joinpath(ros_header_dir,"ros/ros.h"))
    cxx"""
    int argc;
    char **argv;
    //ros::init(argc, argv, "test_node");
    //ros::NodeHandle nh;
    """
end

spin() = @cxx ros::spin()
ok() = @cxx ros::ok()

init()
#spin()
ok()