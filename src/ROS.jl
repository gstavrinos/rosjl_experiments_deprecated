#!/usr/bin/env julia
module ROS
ENV["JULIA_CXX_RTTI"]=1
using Cxx
using Libdl

export @rosinclude, init, ok, spin, spinOnce, NodeHandle, advertise, subscribe

include("publisher.jl")
include("subscriber.jl")
include("nodehandle.jl")

# -------------------------------------------------------------------
# roscpp functions
# -------------------------------------------------------------------
spin() = @cxx ros::spin()
spinOnce() = @cxx ros::spinOnce()
ok() = @cxx ros::ok()
init(node_name::String) = @cxx ros::init(Int32(length(ARGS)+1), pointer(pointer.(pushfirst!(ARGS,PROGRAM_FILE))), pointer(node_name))


# TODO support init options

# TODO investigate this further
NodeHandle() = @cxxnew ros::NodeHandle()

# -------------------------------------------------------------------
# macro definitions
# -------------------------------------------------------------------
macro rosinclude(expr)
    n = replace(string(expr), " " => "")
    n = replace(n, "(" => "")
    n = replace(n, ")" => "")
    toinclude = split(n,':')
    if length(toinclude) != 2
        throw(ErrorException("Error while trying to read @rosinclude " * n))
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
            typeGenerator(pkg, header_file, package_dir)
        end
    end
end



# -------------------------------------------------------------------
# Helper functions and vars
# -------------------------------------------------------------------

types = Dict()

service_types = Dict()

# TODO fix this eval, global-setting mess!!!!
function Base.setproperty!(rostype::Union{Cxx.CxxCore.CppPtr, Cxx.CxxCore.CppValue}, field::Symbol, value) 
    global uglyhack = rostype
    operator = rostype isa Cxx.CxxCore.CppValue ? "." : "->"
    if value isa String
        x = Expr(:macrocall, Symbol("@icxx_str"), nothing, "\$(uglyhack)$(operator)$(string(field))=\"$(value)\";")
        eval(x)
    else
        x = Expr(:macrocall, Symbol("@icxx_str"), nothing, "\$(uglyhack)$(operator)$(string(field))=$(value);")
        eval(x)
    end

end

# TODO fix this eval, global-setting mess!!!!
function Base.getproperty(rostype::Union{Cxx.CxxCore.CppPtr, Cxx.CxxCore.CppValue}, field::Symbol)
    global uglyhack = rostype
    #eval(Meta.parse("@cxx uglyhack->"*string(field)))
    operator = rostype isa Cxx.CxxCore.CppValue ? "." : "->"
    x = Expr(:macrocall, Symbol("@icxx_str"), nothing, "\$(uglyhack)$(operator)$(string(field));")
    eval(x)
end

function typeGenerator(pkg, header_file, package_dir)
    type_name = pkg * "_" * header_file
    rostype_name = pkg * "::" * header_file
    type_generation = "const " * type_name * "=cxxt\"" * rostype_name * "\""
    class_generation = type_name * "()=@cxxnew " * rostype_name * "()"
    type_export = "export " * type_name
    eval(Meta.parse(type_generation))
    eval(Meta.parse(class_generation))
    eval(Meta.parse(type_export))

    # Additional steps for services
    # One of the two checks is fine, but I make both just to be completely sure
    if isfile(joinpath(package_dir, header_file * "Request.h")) && isfile(joinpath(package_dir, header_file * "Request.h"))
        cxxinclude(joinpath(package_dir, header_file * "Request.h"))
        cxxinclude(joinpath(package_dir, header_file * "Response.h"))
        type_name_req = type_name * "_Request"
        type_name_res = type_name * "_Response"
        rostype_name_req = pkg * "::" * header_file * "::Request"
        rostype_name_res = pkg * "::" * header_file * "::Response"
        type_generation_req = "const " * type_name_req * "=cxxt\"" * rostype_name_req * "\""
        type_generation_res = "const " * type_name_res * "=cxxt\"" * rostype_name_res * "\""
        class_generation_req = type_name_req * "()=@cxxnew " * rostype_name_req * "()"
        class_generation_res = type_name_res * "()=@cxxnew " * rostype_name_res * "()"
        type_export_req = "export " * type_name_req
        type_export_res = "export " * type_name_res
        eval(Meta.parse(type_generation_req))
        eval(Meta.parse(type_generation_res))
        eval(Meta.parse(class_generation_req))
        eval(Meta.parse(class_generation_res))
        eval(Meta.parse(type_export_req))
        eval(Meta.parse(type_export_res))
        service_types[eval(Meta.parse("cxxt\"" * rostype_name * "\""))] = [eval(Meta.parse("cxxt\"" * rostype_name_req * "\"")), eval(Meta.parse("cxxt\"" * rostype_name_res * "\""))]
    end
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
