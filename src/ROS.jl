#!/usr/bin/env julia
module ROS
ENV["JULIA_CXX_RTTI"]=1
using Cxx
using Libdl

export @rosinclude, init, ok, spin, spinOnce, NodeHandle, advertise, subscribe

#include("todo.jl")

# -------------------------------------------------------------------
# roscpp functions
# -------------------------------------------------------------------
spin() = @cxx ros::spin()
spinOnce() = @cxx ros::spinOnce()
ok() = @cxx ros::ok()
init(node_name::String) = @cxx ros::init(Int32(length(ARGS)+1), pointer(pointer.(pushfirst!(ARGS,PROGRAM_FILE))), pointer(node_name))


# TODO support init options
# TODO support TransportHints in subscribe function

# TODO investigate this further
NodeHandle() = @cxxnew ros::NodeHandle()
# TODO investigate this further
advertise(nodehandle, topic_name::String, topic_type, queue_size::Int) = icxx"$(nodehandle)->advertise<$(topic_type)>($(pointer(topic_name)), $(queue_size));"
# TODO investigate this further
publish(publisher, msg) = icxx"$(publisher).publish(*$(msg));"
# TODO investigate this further
function subscribe(nodehandle, topic_name::String, queue_size::Int, topic_type, callback)
    #icxx"$(nodehandle)->subscribe($(pointer(topic_name)),$(queue_size),&($(test)));"
    icxx"""
        //std::function<void (sensor_msgs::Imu::ConstPtr)> cb = [&](sensor_msgs::Imu::ConstPtr msg) {
        boost::function<void ($(topic_type))> cpp_callback = [&]($(topic_type) msg) {
            $:(callback(icxx"return msg;"));
        };
        return $(nodehandle)->subscribe<$(topic_type)>($(pointer(topic_name)), $(queue_size), cpp_callback);
    """
end



# -------------------------------------------------------------------
# macro definitions
# -------------------------------------------------------------------
macro rosinclude(expr)
    n = replace(string(expr), " " => "")[2:end-1]
    toinclude = split(n,':')
    if length(toinclude) != 2
        throw(ErrorException("Error while trying to read @rosinclude "*n))
    end
    pkg = string(toinclude[1])
    package_dir = unsafe_string(icxx"ros::package::getPath($(pointer(pkg)));")
    if length(package_dir) > 0
        additional_folder = ""
        if occursin("/src/", package_dir) # the package was found in a catkin workspace, and not inside the ROS installation (/opt/ros/...)
            additional_folder = "devel/"
        end
        package_dir = normpath(package_dir, "../..") * additional_folder * "include/" * pkg * "/"
        for header_file in split(toinclude[2],',')
            cxxinclude(joinpath(package_dir, header_file * ".h"))
            typeGenerator(pkg, header_file)
        end
    end
end



# -------------------------------------------------------------------
# Helper functions and vars
# -------------------------------------------------------------------

types = Dict()

# TODO fix this eval, meta-parsing, global-setting mess!!!!
function Base.setproperty!(rostype::Union{Cxx.CxxCore.CppPtr, Cxx.CxxCore.CppValue}, field::Symbol, value) 
    global uglyhack = rostype
    operator = rostype isa Cxx.CxxCore.CppValue ? "." : "->"
    eval(Meta.parse("icxx\"\$(uglyhack)"*operator*string(field)*"=$(value);\""))

end

# TODO fix this eval, meta-parsing, global-setting mess!!!!
function Base.getproperty(rostype::Union{Cxx.CxxCore.CppPtr, Cxx.CxxCore.CppValue}, field::Symbol)
    global uglyhack = rostype
    eval(Meta.parse("@cxx uglyhack->"*string(field)))
end

function typeGenerator(pkg, header_file)
    type_name = pkg * "_" * header_file
    rostype_name = pkg * "::" * header_file
    type_generation = "const " * type_name * "=cxxt\"" * rostype_name * "\""
    class_generation = type_name * "()=@cxxnew " * rostype_name * "()"
    type_export = "export " * type_name

    println(type_generation)
    eval(Meta.parse(type_generation))
    println(class_generation)
    eval(Meta.parse(class_generation))
    println(type_export)
    eval(Meta.parse(type_export))
end

function ros♥julia()
    try
        ros_root = normpath(joinpath(ENV["ROS_ROOT"], "../.."))
        ros_header_dir = ros_root * "include"
        ros_lib_dir = ros_root * "lib"
        addHeaderDir(ros_header_dir, kind = C_System)
        cxxinclude(joinpath(ros_header_dir,"ros/ros.h"))
        cxxinclude(joinpath(ros_header_dir,"ros/package.h"))
        #cxxinclude(joinpath(ros_header_dir,"ros/message_traits.h"))
        Libdl.dlopen(joinpath(ros_lib_dir, "libroscpp.so"), Libdl.RTLD_GLOBAL)
        Libdl.dlopen(joinpath(ros_lib_dir, "libroslib.so"), Libdl.RTLD_GLOBAL)
        #Libdl.dlopen(joinpath(ros_lib_dir, "libroscpp_serialization.so"), Libdl.RTLD_GLOBAL)
        println(pushfirst!(ARGS,PROGRAM_FILE))
    catch
        throw(ErrorException("ROS.jl cannot find your ROS installation! ¯\\_(ツ)_/¯"))
    end
end

ros♥julia()

end
